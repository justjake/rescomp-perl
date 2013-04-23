use strict;
use warnings;

sub min {
    my $least = shift @_;
    foreach (@_) {
        $least = $_ if $_ < $least;
    }
    return $least;
}

# doing it wrong
# ugly memoization
our $fun_sep = '-:|:-';

# array -> string
sub fun_join {
    return join($fun_sep, @_);
}

# string -> array
sub fun_split {
    return split($fun_sep, @_);
}

my $debug_memo = 0;

# memoize a function, given that the function accepts only scalar values
sub memoize_scalar {
    my $fn_ref = shift @_;
    my %calls  = ();

    return sub {
        # return memoized result
        print "memoize call for [@_]..." if $debug_memo;
        my $args_s = fun_join(@_);
        if (exists $calls{$args_s}) {
            print " cache hit! $args_s\n" if $debug_memo;
            return $calls{$args_s}
        }

        #store result then return
        my $res = $fn_ref->(@_);
        $calls{$args_s} = $res;
        print " cache miss. $args_s\n" if $debug_memo;
        return $res;
    }
}


# compare two strings. Counts the number of differences
# between them
sub diff_naive {
    # operate on our strings as arrays
    my @a = split(//, shift @_);
    my @b = split(//, shift @_);
    
    # scalar coersion to get lenght
    my $maxlen;
    $maxlen = scalar @a if scalar @a >  scalar @b;
    $maxlen = scalar @b if scalar @b >= scalar @a;

    my $score = 0;

    # increment score for each difference
    for (my $i = 0; $i < $maxlen; $i++) {
        if (defined $a[$i] and defined $b[$i]) {
            # compare character in string
            $score++ if $a[$i] ne $b[$i];
        } else {
            # one string is longer
            $score++;
        }
    }

    return $score;
}

# #simplify
sub j {
    join('', @_)
}

# http://en.wikipedia.org/wiki/Levenshtein_distance
# call lev_dist("some", "string", \&lev_dist);
my $lev;

sub lev_dist {
    my @s = split(//, shift @_);
    my @t = split(//, shift @_);
    # print "lev dist: comparing $s and $t\n";

    # empty strings
    return $#s if $#t == 0;
    return $#t if $#s == 0;

    # last characters match?
    my $cost;
    if ($s[-1] eq $t[-1]) {
        $cost = 0;
    } else {
        $cost = 1;
    }

    # min of delchar s, delchar t, delcahr s delchar t.
    return min(
        $lev->( j(@s[0..$#s-1]),   j(@t)        )    + 1,
        $lev->( j(@s),             j(@t[0..$#t-1]) ) + 1,
        $lev->( j(@s[0..$#s-1]),   j(@t[0..$#t-1]) ) + $cost
    )
}

$lev = memoize_scalar(\&lev_dist);
#$lev = \&lev_dist;
# my $best_diff = memoize_scalar(\&diff_naive);
my $best_diff = $lev;

sub diff_vs_file {
    my $word = shift;
    my $path = shift;

    my $best; # the most similar word so far
    my $min = 9**9**9**9; # large number, similarity score for $best

    # open the file
    open(my $file, '<', $path) || die "Failed to open $path because $!\n";

    my $diff;
    while(my $other = <$file>) {
        chomp $other;
        $diff = $best_diff->($word, $other);
        if ($diff <= $min) {
            $min = $diff;
            $best = $other;
        }
    }

    return ($best, $min);
}

print "Diffing word $ARGV[0] vs file $ARGV[1]\n";
my @closest = diff_vs_file($ARGV[0], $ARGV[1]);
print "closest was @closest\n";
