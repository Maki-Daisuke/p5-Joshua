on 'develop' => sub {
    requires 'Module::Install';
    requires 'Module::Install::CPANfile';
    requires 'Module::Install::AuthorTests';
    requires 'Module::Install::Repository';
};

requires 'parent';
requires 'AnyEvent';
requires 'AnyEvent::DBI::Abstract';
requires 'Carp';
requires 'DBD::SQLite';
requires 'Exporter';
requires 'File::Spec';
requires 'Try::Tiny';
