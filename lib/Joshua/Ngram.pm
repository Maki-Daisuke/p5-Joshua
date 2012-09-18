package Joshua::Ngram;

use 5.010;

use parent 'Exporter';
our @EXPORT_OK = qw(
    ngram_iterator   ngram
    bigram_iterator  bigram
    trigram_iterator trigram
);


sub ngram_iterator {
    my ($n, $text) = @_;
    utf8::upgrade($text);
    my $index = 0;
    my $pos   = 0;
    return sub {
        return  if $pos > length($text) - $n;
        return (substr($text, $pos, $n), $n, $pos, $pos++ + $n, $index++);
    }
}

sub ngram {
    my $it = ngram_iterator(@_);
    my @r;
    while ( my ($term) = $it->() ) {
        push @r, $term;
    }
    @r;
}

sub bigram_iterator {
    ngram_iterator(2, @_);
}

sub bigram {
    ngram(2, @_);
}

sub trigram_iterator {
    ngram_iterator(3, @_);
}

sub trigram {
    ngram(3, @_);
}


1;
