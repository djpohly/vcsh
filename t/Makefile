.PHONY: all test test-prereq test-results

all: test

test-prereq:
	@if ! which git   > /dev/null; then echo "'git' not found, exiting..."         ; exit 1; fi
	@if ! which prove > /dev/null; then echo "'prove' not found; not running tests"; exit 1; fi

test: test-prereq
	prove $(filter -j%,$(MAKEFLAGS)) *.t :: $(TEST_ARGS)

test-results:
	for f in test-results/*.out; do \
		echo "=== $$f ==="; \
		cat "$$f"; \
		echo; \
	done
