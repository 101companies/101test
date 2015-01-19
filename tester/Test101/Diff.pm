package Test101::Diff;
use strict;
use warnings;
use Test::More;
use YAML;

use Class::Tiny qw(diff tests);


sub BUILD
{
    my ($self, $args) = @_;

    my %diff = map
    {
        my $path = m{^/} ? $_ : "$args->{results}/$_";
        ($path => $args->{arg}{$_})
    } keys %{$args->{arg}};

    $self->diff (\%diff);
    $self->tests(1);
}


sub test
{
    my ($self, $args) = @_;
    local ($YAML::UseHeader, $YAML::SortKeys) = (0, 1);
    is_deeply $args->{diff}, $self->diff, "diff is:\n" . Dump($self->diff);
}


1
