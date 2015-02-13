use strict;
use warnings;
use Test::More;

my @modules = qw(
    Class::Tiny
    File::Slurp
    IPC::Run
    List::MoreUtils
    JSON::Schema
    Test::Deep
    Test::Most
    YAML
);

plan tests => scalar @modules;

for (@modules)
{
    require_ok $_ or BAIL_OUT "Couldn't load module: $_, please "
                            . "install it with ``cpan install $_''";
}
