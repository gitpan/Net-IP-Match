use Test::More tests => 22;
BEGIN { use_ok('Net::IP::Match') }

while (<DATA>) {
    chomp;
    my $should = substr($_, 0, 1, '') eq '+';
    my $match = __MATCH_IP($_, qw{10.0.0.0/8 87.134.66.128
	87.134.87.0/24 145.97.0.0/16});
    is($match, $should, $_);
}

my $ip = '192.168.1.4';
ok( __MATCH_IP($ip, '192.168.7.18/16'),
    'two strings that match');
ok( !__MATCH_IP($ip, '10.2.3.4/8'),
    'two strings that do not match');
ok(  __MATCH_IP($ip, '192.168.7.18/16') && !__MATCH_IP($ip, '10.2.3.4/8'),
    'complex condition');

__DATA__
+10.0.1.38
-12.220.206.11
-12.225.186.217
-87.134.66.127
+87.134.66.128
-87.134.86.26
+87.134.87.26
-128.101.91.70
-128.105.2.10
-128.252.19.2
-132.185.132.11
-137.158.128.1
+145.97.1.6
+145.97.11.1
+145.97.200.63
-145.974.216.202
-192.100.59.100
-192.168.0.0
