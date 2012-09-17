use inc::Module::Install;
name 'Searchd';
version '0.1';

requires 'parent';
requires 'AnyEvent';
requires 'AnyEvent::DBI::Abstract';
requires 'Carp';
requires 'DBD::SQLite';
requires 'Exporter';
requires 'File::Spec';
requires 'Try::Tiny';

WriteAll;
