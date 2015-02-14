package Test101::Case;
use strict;
use warnings;
use IPC::Run   qw(run);
use List::Util qw(reduce);
use Test::More;

use constant VALIDATORS => qw(diff indiff files);
require "Test101/\u$_.pm" for VALIDATORS;

use Class::Tiny qw(number command branch validators result);


sub BUILD
{
    my ($self, $args) = @_;
    my  $tests        = 1;

    my @validators;
    for (VALIDATORS)
    {
        next if not exists $args->{$_};
        my $class = "Test101::\u$_";
        push @validators, $class->new(%$args, arg => $args->{$_})
    }

    $self->validators(\@validators);
}

sub test_count
{
    my ($self) = @_;
    reduce { $a + $b->test_count } 1, @{$self->validators}
}


sub test
{
    my ($self)          = @_;
    $ENV{repo101branch} = $self->branch;

    subtest "case ${\$self->number}, branch ${\$self->branch}" => sub
    {
        plan tests => $self->test_count;

        my ($exec, $in) = ([split /\s+/, $self->command]);
        ok run($exec, \$in), 'command ran ok: ' . $self->command;
        note "command exited with $?";

        my %diff = do
        {
            if (open my $result, '<', $self->result)
            {   map { chomp; reverse split /\s+/, $_, 2 } <$result> }
            else
            {
                warn "Can't open ${\$self->result}: $!";
                ()
            }
        };

        my $args = {
            number => $self->number,
            branch => $self->branch,
            diff   => \%diff,
        };

        $_->test($args) for @{$self->validators};
    };
}


1
