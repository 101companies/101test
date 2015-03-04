WORKER_ENV_WARNING = \
echo 'Environment variable worker101dir is not set, but the'; \
echo 'tests need to know where 101worker is on your computer.'; \
echo 'Use "export worker101dir=/path/to/101worker" to set the path.';


info: list
	@echo 'You can use "make TESTNAME.test" to run the test'
	@echo 'called TESTNAME and "make all" to run all tests.'
	@echo 'You can also use "make parallel" to run all tests in parallel".
	@echo 'For verbose output, you can set the environment variable'
	@echo 'PROVE_ARGS to -v, meaning you run make as follows:'
	@echo '    PROVE_ARGS=-v make TARGET'
	@if [ -z "$$worker101dir" ]; \
	then \
	    echo; \
	    $(WORKER_ENV_WARNING) \
	fi


install:
	cpan Class::Tiny File::Slurp IPC::Run List::MoreUtils \
	     JSON::Schema Test::Deep Test::Most Try::Tiny YAML


clean:
	rm -rf output generated


list:
	@echo 'The following tests are available:'
	@ls -1 config | sort | sed 's/\.yml$$//' | sed 's/^/    - /'


generated/%.t:
	mkdir -p generated
	echo "exec 'perl',"                        > $@
	echo "     'tester',"                     >> $@
	echo "     '--schema=config.schema.yml'," >> $@
	echo '     "--cd=$$ENV{worker101dir}",'   >> $@
	echo "     '--config=config/$*.yml',"     >> $@
	echo "     '--output=output/$*'"          >> $@


%.test: worker-dir
	make -s generated/$*.t
	rm -rf output/$*
	prove $(PROVE_ARGS) generated/$*.t


all: worker-dir
	make -s `ls -1 config | sort | sed 's/^/generated\//' | sed 's/\.yml$$/.t/'`
	rm -rf output
	prove $(PROVE_ARGS) generated


parallel:
	jobs=`ls -1 config | wc -l`; PROVE_ARGS="$$PROVE_ARGS -j $$jobs" make -s all


worker-dir:
	@if [ -z "$$worker101dir" ]; \
	then \
	    $(WORKER_ENV_WARNING) \
	    exit 1; \
	fi


.PHONY: install clean info list %.test all worker-dir
