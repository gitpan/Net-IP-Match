package Net::IP::Match;

require 5.005_62;
use strict;
use warnings;
use Filter::Simple;

our $VERSION = '0.01';

FILTER sub {
    	s[\b __MATCH_IP \s* \( (.*?) \s* , \s* (.*?) \s* \) ]
	 [
	    my @n = eval $2;
	    my @t;
	    for (@n) {
		    my ($quad, $bits) = m!^(\d+\.\d+\.\d+\.\d+)(?:/(\d+))?!g;
		    my $matchbits = 32 - ($bits || 32);
		    my $int = unpack("N", pack("C4", split(/\./, $quad)));
		    my $mask = $int >> $matchbits;
		    push @t => { mask => $mask, bits => $matchbits };
	    }

	    my $unpack_code = qq!unpack("N", pack("C4", split(/\\./, $1)))!;

	    # if there's only one ip range to match against, we don't need
	    # the temp variable and the do-block, so it's even faster

	    if (@t == 1) {
		    local $_ = shift @t;
		    "($_->{mask} == $unpack_code" .
			($_->{bits} ? " >> $_->{bits}" : "") . ")"
	    } else {
		    my $var = '$__tmp_match_ip';
		    my $cond = join ' || ' => map { "$_->{mask} == $var" .
			($_->{bits} ? " >> $_->{bits}" : "") } @t;
		    qq!do { my $var = $unpack_code; $cond }!
	    }

	 ]gsex;
	 print if $::debug;
};

1;
__END__

=head1 NAME

Net::IP::Match - Efficiently match IP addresses against IP ranges

=head1 SYNOPSIS

  use Net::IP::Match;

  if(__MATCH_IP($_, qw{10.0.0.0/8 87.134.66.128
    87.134.87.0/24 145.97.0.0/16})) {
    	...
  }

=head1 DESCRIPTION

This module provides you with an efficient way to match an IP
address against one or more IP ranges. Speed is the key issue here.
If you have to check several million IP addresses, as can happen
with big logs, every millisecond counts. If your way to check an
address involves a method call and some temporary variables, a lot
of time is burnt. In such a time-critical loop you don't want to
make subroutine calls at all, as they involve stack operations.

So the approach we take here is that of a macro, preprocessed
through Perl's source filter mechanism.

You get a function (or at least something that looks like a function)
called C<__MATCH_IP> that takes a string that is to be matched
against one or more IP ranges which are specified as the remaining
args. The first argument can be a literal string or a variable;
the other args can only be literal strings.

The function returns a boolean value depending on whether there is
a match.

For example, the following are legal:

  __MATCH_IP('192.168.1.4', '192.168.0.0/16')
  __MATCH_IP('192.168.1.4', '10.0.0.0/8', '202.175.29.0/24')
  __MATCH_IP($some_ip, qw{ 10.0.0.0/8 202.175.29.0/24 })

The following won't work because the source filter doesn't handle
nested parentheses:

  __MATCH_IP('192.168.1.4', ('10.0.0.0/8', '202.175.29.0/24'))

The following won't work because the source filter is invoked at
compile-time, so the ranges to be transformed need to be known at
that time:

  __MATCH_IP($some_ip, @ranges)

=head1 INTERNALS

The source filter turns this function into a series of bit shift
and short-circuit logical OR operations. No subroutine calls are
involved. For example, the following call:

  __MATCH_IP('192.168.1.4', qw{ 10.0.0.0/8 192.168.0.0/16 })

would be turned into:

  do {
    my $__tmp_match_ip = unpack("N", pack("C4", split(/\./, '192.168.1.4')));
    10 == $__tmp_match_ip >> 24 || 49320 == $__tmp_match_ip >> 16
  }

As a special case, if you're matching against a specific IP address
(as opposed to a range), no bit shifts are involved:

  __MATCH_IP($some_ip, qw{ 10.0.0.0/8 192.168.1.4 })

becomes

  do {
    my $__tmp_match_ip = unpack("N", pack("C4", split(/\./, $some_ip)));
    10 == $__tmp_match_ip >> 24 || 3232235780 == $__tmp_match_ip
  }

Furthermore, if there is only one IP range to match against, the
temporary variable and the do-block aren't necessary either:

  __MATCH_IP($some_ip, '192.168.0.0/16')

becomes:

  (49320 == unpack("N", pack("C4", split(/\./, $some_ip))) >> 16)

and that's about as efficient as it gets.

=head1 DEBUGGING

If you want to see the output of the source filter, set C<$::debug>
to a true value by the time the source filter runs. One way to
achieve this is:

  perl -s my_program.pl -debug

=head1 ALTERNATIVE APPROACHES

Of course, a C implementation would have been even faster, but you
would have to call it as a function, which would add the stack
overhead. Richard Clamp had the interesting idea of optimizing the
generated opcode tree.

=head1 BUGS

None known so far. If you find any bugs or oddities, please do
inform the author.

=head1 AUTHOR

Marcel GrE<uuml>nauer, <marcel@cpan.org>

=head1 COPYRIGHT

Copyright 2002 Marcel GrE<uuml>nauer. All rights reserved.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 SEE ALSO

perl(1).

=cut
