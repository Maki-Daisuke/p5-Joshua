package Joshua;
use 5.010;

use utf8;
use parent 'AnyEvent::DBI::Abstract';

use AnyEvent;
use DBD::SQLite;

use Joshua::Ngram;


sub new {
    my ($class, $dbfile, @opts) = @_;
    my $self = $class->AnyEvent::DBI::Abstract::new("dbi:SQLite:dbname=$dbfile","","", @opts, exec_server => 0);
}

sub init {
    my $self = shift;
    my $cv = AE::cv;
    $self->exec(qq{
        CREATE VIRTUAL TABLE files USING fts3 (
            id           INTEGER  PRIMARY KEY AUTOINCREMENT,  -- Primary key
            path         TEXT     UNIQUE                   ,  -- Absolute path of this file
            search_text  TEXT                              ,  -- Text to be indexed for FTS
            time         INTEGER                           ,  -- UNIX epoch time when Joshua indexed
            tokenize=perl '@{[ __PACKAGE__ ]}::_tokenizer'
        );
        CREATE UNIQUE INDEX idx_files_path ON files(path);
    }, sub{
        my (undef, undef, $rv) = @_;
        if ( $#_ ) {
            $cv->send($rv);
        } else {
            $cv->croak($@);
        }
    });
    $cv;
}

sub _tokenizer {
    \&Joshua::Ngram::bigram_iterator;
}

sub add {
    my ($self, $path, $text) = @_;
    unless ( $text ) {
        $text = $path;
        utf8::decode($text);
    }
    $text = _normalize($text);
    my $cv = AE::cv;
    $self->insert('files', {path => $path, search_text => $text}, sub{
        my (undef, undef, $rv) = @_;
        if ( $#_ ) {
            $cv->send($rv);
        } else {  # Violation of UNIQUE constraint
            $self->update('files', {search_text => $text}, {path => $path}, sub{
                (undef, undef, $rv) = @_;
                if ( $#_ ) {
                    $cv->send($rv);
                } else {
                    $cv->croak($@);
                }
            });
        }
    });
    $cv;
}

sub _normalize {
    my $_ = shift;
    s/[\P{Letter}_]+/-/g;
    lc $_;
}

sub search {
    my ($self, $query) = @_;
    my @words = map{ _normalize $_ } split /\s+/, $query;
    my $cv = AE::cv;
    $cv->send  unless @words;
    $self->select('files', ['path'], {
        search_text => [ -and => {'MATCH' => _normalize($query)}    ,
                                 (map{ {'LIKE'  => "%$_%"} } @words) ]
    }, sub {
        my (undef, $arr, $rv) = @_;
        if ( $#_ ) {
            $cv->send(map{ $_->[0] } @$arr);
        } else {
            $cv->croak($@);
        }
    });
    $cv;
}

sub delete {
    my ($self, $path) = @_;
    my $cv = AE::cv;
    $self->delete('files', {path => $path}, sub{
        my (undef, undef, $rv) = @_;
        if ( $#_ ) {
            $cv->send($rv);
        } else {
            $cv->croak($cv);
        }
    });
    $cv;
}


1;
