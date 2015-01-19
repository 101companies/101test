package Test101::Case;
use strict;
use warnings;
use IPC::Run   qw(run);
use Test::More;

use constant VALIDATORS => qw(diff files);
require "Test101/\u$_.pm" for VALIDATORS;

use Class::Tiny qw(number command branch tests validators);


sub BUILD
{
    my ($self, $args) = @_;
    my  $tests        = 1;

    my @validators = map
    {
        return () if not exists $args->{$_};
        my $validator = "Test101::\u$_"->new(%$args, arg => $args->{$_});
        $tests       += $validator->tests;
        $validator
    } VALIDATORS;

    $self->validators(\@validators);
    $self->tests     ( $tests     );
}


sub test
{
    my ($self)          = @_;
    $ENV{repo101branch} = $self->branch;
    note sprintf 'case %d, branch %s', $self->number, $self->branch;

    my ($in, $out);
    run($self->command, \$in, \$out);
    cmp_ok $?, '==', 0, "``@{$self->command}'' exited with code 0";

    my %diff = map { /^\s*([AMD])\s+(.+?)\s*$/ ? ($2 => $1) : () }
                   split /\n/, $out;
    my $args = {
        number => $self->number,
        branch => $self->branch,
        tests  => $self->tests,
        diff   => \%diff,
    };

    $_->test($args) for @{$self->validators};
}


1
