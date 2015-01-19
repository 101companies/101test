package Test101::File;
use strict;
use warnings;
use File::Slurp     qw(slurp);
use List::MoreUtils qw(true);
use Test::More;

use constant FILE_TESTS => qw(content);
use Class::Tiny qw(path), FILE_TESTS, {exists => 1};


sub BUILD
{
    my ($self, $args) = @_;

    if (!$self->exists)
    {
        my $path = $self->path;
        for (FILE_TESTS)
        {
            die "Can't check $_ on $path when the file isn't supposed to exist"
                if defined $self->$_;
        }
    }
}

sub test_count
{
    my ($self) = @_;
    1 + true { defined $self->$_ } FILE_TESTS;
}


sub test
{
    my ($self, $args) = @_;
    my $path   = $self->path;
    my $exists = -e $path;

    if ($self->exists)
    {
        ok $exists, "file exists: $path";
        $self->file_tests($path, $exists);
    }
    else
    {   ok !$exists, "file does not exist: $path" }
}

sub file_tests
{
    my ($self, $path, $exists) = @_;
    my $content;
    for (FILE_TESTS)
    {
        next if not defined $self->$_;
        if ($exists)
        {
            $content //= slurp $path;
            my $method = "test_$_";
            $self->$method($path, $content);
        }
        else
        {   fail "can't run $_ because file doesn't exist: $path" }
    }
}

sub test_content
{
    my ($self, $path, $content) = @_;
    is $content, $self->content, "content of $path is:\n$content";
}


1
