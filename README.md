test101
=======

Test repo used in 101worker.

These tests are *functional tests* of the 101worker system, not small-scale unit tests.


Installation
------------

Run `make install` to install the tester's required dependencies.

You will also have to clone [101worker](https://github.com/101companies/101worker).


Running Tests
-------------

Before running any tests, you have to set the environment variable `worker101dir` to the absolute path of 101worker's directory on your computer so that the tests can find it. For example, assuming you cloned the repo into `/var/101companies/101worker`, the command to set the enviroment variable until the end of the session is `export worker101dir=/var/101companies/101worker`.

If you want verbose test output, you can also `export PROVE_ARGS=-v`.

After this, you can use `make all` to run all available tests or `make test.TESTNAME` to run the test called TESTNAME. For a list of tests, type `make list`.


Test Structure
--------------

Each *test* consists of one or more *test cases*, which are numbered starting from 1. During each test case, a *branch* from this repository may be checked out to simulate a pull with changed files, a *command* will be executed and then the results of that command will be *validated*.

The tests are based off of declarative definition files found in the [config](config) folder, which must follow the schema given in [config.schema.yml](config.schema.yml). The tests are then run and validated automatically using `prove` and the [tester](tester) program in this repo.


Creating Tests
--------------

Each test consists of a test definition and, optionally, branches in this repository.

The test definition declares the number of tests, commands to be run, branches to be checked out and validations to be performed in each step.

The branches exist to emulate changes in 101repo between runs of 101worker.


### Test Definition

The test definition is written in YAML, which is similar to JSON, but much easier to edit and read by humans. There is a schema definition in the [config.schema.yml](config.schema.yml). The test definitions are to be placed in the [config](config) folder and must end with `.yml` so that they work properly with the [Makefile](Makefile).

In absence of a tutorial, see existing test definitions and the schema to write your own tests.


### Branches

Branches are used to imitate changes in 101repo between pulls. In each test case, a different branch can be specified. When running a test, the environment variable `repo101branch` is set to the appropriate value. The 101worker module `pull101repo` will correctly detect this, checkout the branch and create a diff between it and the branch from the previous test case.

It is recommended that you name your branches `$test_name$test_case_number`, so that you won't need to manually specifiy the branch names in your definition file. For example, if you test is called *pull* and the branch is for the *4th* test case, you'd call the branch `pull4`.

To create an empty branch, run `git checkout --orphan BRANCHNAME`. You can (and probably should) run `git rm -rf .` and `rm -rf *` to clear your branch of all files and actually start from an empty branch. Then add any files you want, `git add` and `git commit` them as normal. To push the branch to the Github repo, you have to run `git push -u origin $(git rev-parse --abbrev-ref HEAD)` (the thing within the `$()` resolves to your current BRANCHNAME).

For the next test case, run `git checkout -b BRANCHNAME` (note: `-b` instead of `--orphan`). Then add/modify/delete files as necessary, commit and push your branch as above. Then repeat for the next test case.


Validators
----------

Validators are used to test for certain conditions. For example, the [DiffValidator](Test101/DiffValidator.pm) checks for the correct diff output.

To define a new validator, first extend the schema at [config.schema.yml](config.schema.yml) by the attributes your validator expects. Then create a new Perl module file in the [Test101 folder](Test101).

The name of your attribute and validator need to match up. For example, if your attribute is called `frobnicate`, the validator needs to be called `FrobnicateValidator.pm`. It will automatically be discovered by the test runner and passed the correct attributes.

Each validator has to implement the following subroutines:

* `new`

```perl
new($class, %args)
```

Construct an instance of your validator. The data decoded from your attribute will be in `$args{arg}`.

* `test_count`

```perl
test_count()
```

This must return the number of tests your validator is going to run.

* `test`

```perl
$self->test({
    number => 'test case number',
    branch => 'current branch name',
    diff   => {'/absolute/path' => /^[AMD]$/, ...}
})
```

Actually run your tests, using `Test::More` or something similar.
