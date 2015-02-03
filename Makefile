WORKER_ENV_WARNING = \
echo 'Environment variable worker101dir is not set, but the'; \
echo 'tests need to know where 101worker is on your computer.'; \
echo 'Use "export worker101dir=/path/to/101worker" to set the path.';


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


install:
	cpan install Class::Tiny File::Slurp IPC::Run List::MoreUtils
	             JSON::Schema Test::Most YAML


clean:
	rm -rf results generated


list:
	@echo 'The following tests are available:'
	@ls config | sort | sed 's/\.yml$$//' | sed 's/^/    - /'


generated/%.t:
	mkdir -p generated
	echo "exec 'perl',"                              > $@
	echo "     'tester',"                           >> $@
	echo "     '--schema=config.schema.yml',"       >> $@
	echo '     "--cd=$$ENV{worker101dir}/modules",' >> $@
	echo "     '--config=config/$*.yml',"           >> $@
	echo "     '--results=results/$*'"              >> $@


%.test: worker-dir
	make generated/$*.t
	rm -rf results/$*
	prove $(PROVE_ARGS) generated/$*.t


all: worker-dir
	make `ls config | sed 's/^/generated\//' | sed 's/\.yml$$/.t/'`
	rm -rf results
	prove $(PROVE_ARGS) generated


worker-dir:
	@if [ -z "$$worker101dir" ]; \
	then \
	    $(WORKER_ENV_WARNING) \
	    exit 1; \
	fi


.PHONY: install clean info list %.test all worker-dir
