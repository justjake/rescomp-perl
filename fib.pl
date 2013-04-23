use strict;
use warnings;

# naive rescursive implementation
sub fib_r {
    my $n = $_[0];
    return 1 if $n <= 1;
    return fib_r($n - 1) + fib_r($n - 2);
}

print fib_r($ARGV[0]) . "\n";

