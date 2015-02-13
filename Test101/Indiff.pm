package Test101::Indiff;
use strict;
use warnings;
use Test::More;
use YAML;
use Test101::Diff;

use parent qw(Test101::Diff);


sub test_count { scalar keys %{shift->diff} }


sub test
{
    my ($self, $args) = @_;

    while (my ($path, $op) = each %{$self->diff})
    {
        if (defined $op)
        {   is $args->{diff}{$path}, $op, "is in diff: $op $path" }
        else
        {   ok !exists $args->{diff}{$path}, "not in diff: $path" }
    }
}


1
