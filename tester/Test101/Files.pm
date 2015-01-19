package Test101::Files;
use strict;
use warnings;
use List::Util    qw(reduce);
use Test101::File;

use Class::Tiny qw(files tests);


sub BUILD
{
    my ($self, $args) = @_;

    my @files = map
    {
        my $path = m{^/} ? $_ : "$args->{results}/$_";
        Test101::File->new(path => $path, %{$args->{arg}{$_}})
    } keys %{$args->{arg}};

    $self->files(\@files);
    $self->tests(reduce { $a + $b->tests } 0, @files);
}


sub test
{
    my ($self, $args) = @_;
    $_->test($args) for @{$self->files};
}


1
