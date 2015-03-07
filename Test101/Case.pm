package Test101::Case;
use strict;
use warnings;
use IPC::Run   qw(run);
use List::Util qw(pairs reduce);
use Test::More;


our @VALIDATORS;
for (glob 'Test101/*')
{
    if (/(\w+)Validator\.pm$/)
    {
        require;
        push @VALIDATORS, "Test101::$1Validator" => lc $1;
    }
}

use Class::Tiny qw(number command branch validators result);


sub BUILD
{
    my ($self, $args) = @_;
    my  $tests        = 1;

    my @validators;
    for (pairs @VALIDATORS)
    {
        my ($class, $attr) = @$_;
        next if not exists $args->{$attr};
        push @validators, $class->new(%$args, arg => $args->{$attr})
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
