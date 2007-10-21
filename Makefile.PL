use inc::Module::Install;
name 'Net-IP-Match';
all_from 'lib/Net/IP/Match.pm';
perl_version '5.006';

requires 'Filter::Simple';

build_requires 'Test::More' => '0.70';

use_standard_tests;
auto_include;
WriteAll;
