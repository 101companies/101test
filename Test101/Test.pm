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
    my  $config       = $self->config;

    my $valid = JSON::Schema->new($self->schema)->validate($config);
    die join "\n - ", 'Invalid test definition:', $valid->errors if not $valid;

    my (@strings, @numbers);
    for (keys %$config)
    {
        if (/^\d+$/)
        {   push @numbers, $_ }
        else
        {   push @strings, $_ }
    }

    my %base  = map { ($_ => $config->{$_}) } @strings;
    my @cases = map
    {
        Test101::Case->new(
            branch  => "$base{name}$_",
            %base,
            exists $config->{$_} ? %{$config->{$_}} : (),
            number  => $_,
            results => $self->results,
        )
    } 1 .. $config->{tests};

    my @useless = grep { $_ < 1 || $_ > $config->{tests} } @numbers;
    if (@useless)
    {
        warn "Useless test case(s): ", join ', ', sort { $a <=> $b } @useless;
        warn "Test case numbers are between 1 and $config->{tests}.";
    }

    $self->cases(\@cases);
}


sub test
{
    my ($self) = @_;

    chdir $self->cd or die "Couldn't cd into ${\$self->cd}: $!";
    $ENV{results101dir} = $self->results;

    plan tests => scalar @{$self->cases};
    $_->test for @{$self->cases};
}


1
