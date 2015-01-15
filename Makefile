test: worker-dir
	rm -rf results/test
	prove -v tester/tester :: --config=config/test.yml \
	                          --schema=config.schema.yml \
	                          --cd=$$worker101dir/modules \
	                          --results=results/test

worker-dir:
	@if [ -z "$$worker101dir" ]; \
	then \
	    echo '************************************************************'; \
	    echo 'Environment variable worker101dir is not set, but tests need'; \
	    echo 'to know where 101worker is on your computer.'; \
	    echo; \
	    echo 'Use "export worker101dir=/path/to/101worker" to set it.'; \
	    echo '************************************************************'; \
	    exit 1; \
	fi

.PHONY: test worker-dir
