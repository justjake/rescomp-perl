use strict;
use warnings;

sub get_env {
    my $name = shift @_;

    return $ENV{$name};
}

print get_env("USER") . "\n";
