WORKER_ENV_WARNING = \
echo 'Environment variable worker101dir is not set, but the'; \
echo 'tests need to know where 101worker is on your computer.'; \
echo 'Use "export worker101dir=/path/to/101worker" to set the path.';

info:
	@echo 'Nothing to do by default.'
	@echo 'The following tests are available:'
	@ls config | sort | sed 's/\.yml$$//' | sed 's/^/    - /'
	@echo 'You can use "make TESTNAME.test" to run the test'
	@echo 'called TESTNAME and "make all" to run all tests.'
	@if [ -z "$$worker101dir" ]; \
	then \
	    echo; \
	    $(WORKER_ENV_WARNING) \
	fi


%.test: worker-dir
	rm -rf results/$*
	prove $(PROVE_ARGS) tester/tester :: "--schema=config.schema.yml" \
                                         "--cd=$$worker101dir/modules" \
                                         "--config=config/$*.yml" \
                                         "--results=results/$*"


all:
	make `ls config | sed 's/\.yml$$/.test/'`


worker-dir:
	@if [ -z "$$worker101dir" ]; \
	then \
	    $(WORKER_ENV_WARNING) \
	    exit 1; \
	fi


.PHONY: info %.test all worker-dir
