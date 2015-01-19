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

The tests are based off of declarative definition files found in the `config` folder, which must follow the schema given in `config.schema.yml`. The tests are then run and validated automatically using `prove` and the `tester` program in this repo.


Creating Branches
-----------------

Branches are used to imitate changes in 101repo between pulls. In each test case, a different branch can be specified. When running a test, the environment variable `repo101branch` is set to the appropriate value. The 101worker module `pull101repo` will correctly detect this, checkout the branch and create a diff between it and the branch from the previous test case.

It is recommended that you name your branches `$test_name$test_case_number`, so that you won't need to manually specifiy the branch names in your definition file. For example, if you test is called *pull* and the branch is for the *4th* test case, you'd call the branch `pull4`.

To create an empty branch, run `git checkout --orphan BRANCHNAME`. You can (and probably should) run `git rm -rf * .gitignore` to remove all the files from the main branch. Then add any files you want, `git add` and `git commit` them as normal. To push the branch to the Github repo, you have to run `git push -u origin BRANCHNAME`.

For the next test case, create a new branch without the `--orphan` option and don't remove all the files (unless you really want them all gone for the next test case, that is). Otherwise proceed as above.
