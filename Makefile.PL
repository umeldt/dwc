use 5.014000;
use ExtUtils::MakeMaker;

WriteMakefile(
    NAME              => 'DwC',
    VERSION_FROM      => 'lib/DwC.pm',
    PREREQ_PM         => { JSON => 2.0, 'Module::Pluggable' => 5.2 },
    ABSTRACT_FROM     => 'lib/DwC.pm',
    AUTHOR            => 'umeldt <chris@svindseth.jp>',
    LICENSE           => 'perl',
);
