package Test101::Test;
use strict;
use warnings;
use List::Util    qw(reduce);
use JSON::Schema;
use Test::More;
use Test101::Case;

use Class::Tiny qw(config schema cd results cases);


sub BUILD
{
    my ($self, $args) = @_;
    my  $config         = $self->config;

    my $valid = JSON::Schema->new($self->schema)->validate($config);
    die join "\n - ", 'Invalid test definition:', $valid->errors if not $valid;

    my %base  = map { ($_ => $config->{$_}) } grep { !/^\d+$/ } keys %$config;
    my @cases = map
    {
        Test101::Case->new(
            branch  => "$base{name}$_",
            number  => $_,
            results => $self->results,
            %base,
            exists $config->{$_} ? %{$config->{$_}} : (),
        )
    } 1 .. $config->{tests};

    $self->cases(\@cases);
}


sub test
{
    my ($self) = @_;

    chdir $self->cd or die "Couldn't cd into ${\$self->cd}: $!";
    $ENV{results101dir} = $self->results;

    plan tests => reduce { $a + $b->test_count } 0, @{$self->cases};
    $_->test for @{$self->cases};
}


1
