#!/bin/bash

test_description='Clone command'

. test-lib.sh
. "$TEST_DIRECTORY/environment.bash"

test_expect_success 'Clone honors -b option between remote and repo name' \
	'$VCSH clone "$TESTREPO" -b "$TESTBR1" foo &&
	git ls-remote "$TESTREPO" "$TESTBR1" | head -c40 >expected &&
	echo >>expected &&

	$VCSH run foo git rev-parse "$TESTBR1" >output &&
	test_cmp expected output'

test_done