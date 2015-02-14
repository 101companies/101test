package Test101::IndiffValidator;
use strict;
use warnings;
use Test::More;
use YAML;
use Test101::DiffValidator;

use parent qw(Test101::DiffValidator);


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
