package Test101::File;
use strict;
use warnings;
use File::Slurp qw(slurp);
use List::Util  qw(reduce);
use Test::More;

use constant FILE_TESTS => qw(content);
use Class::Tiny qw(path tests), FILE_TESTS, {
    exists => 1,
};


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

    $self->tests(reduce { defined $self->$b ? $a + 1 : $a } 1, FILE_TESTS);
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
