WORKER_ENV_WARNING = \
echo 'Environment variable worker101dir is not set, but the'; \
echo 'tests need to know where 101worker is on your computer.'; \
echo 'Use "export worker101dir=/path/to/101worker" to set the path.';


install:
	cpan install Class::Tiny File::Slurp IPC::Run
	             List::MoreUtils JSON::Schema YAML


info: list
	@echo 'You can use "make TESTNAME.test" to run the test'
	@echo 'called TESTNAME and "make all" to run all tests.'
	@echo 'For verbose output, you can set the environment variable'
	@echo 'PROVE_ARGS to -v, meaning you run make as follows:'
	@echo '    PROVE_ARGS=-v make TARGET'
	@if [ -z "$$worker101dir" ]; \
	then \
	    echo; \
	    $(WORKER_ENV_WARNING) \
	fi


list:
	@echo 'The following tests are available:'
	@ls config | sort | sed 's/\.yml$$//' | sed 's/^/    - /'



%.test: worker-dir
	rm -rf results/$*
	prove $(PROVE_ARGS) tester :: "--schema=config.schema.yml" \
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


.PHONY: install info list %.test all worker-dir
