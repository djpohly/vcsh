#!/bin/bash

test_description='Status command'

. ./test-lib.sh
. "$TEST_DIRECTORY/environment.bash"

test_expect_failure 'Status shows commits behind upstream' \
	'# Test not yet implemented
	false'

test_done
