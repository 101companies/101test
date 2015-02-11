package Test101::Diff;
use strict;
use warnings;
use Test::More;
use YAML;

use Class::Tiny qw(diff);


sub BUILD
{
    my ($self, $args) = @_;

    my %diff = map
    {
        my $path = m{^/} ? $_ : "$args->{output}/$_";
        ($path => $args->{arg}{$_})
    } keys %{$args->{arg}};

    $self->diff(\%diff);
}

sub test_count { 1 }


sub test
{
    my ($self, $args) = @_;
    is_deeply $args->{diff}, $self->diff, "diff is:\n" . Dump($self->diff);
}


1