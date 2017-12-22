#!/bin/bash

test_description='Push command'

. ./test-lib.sh
. "$TEST_DIRECTORY/environment.sh"

test_setup 'set push.default=simple' \
	'git config --global push.default simple'

test_expect_success 'push works with no repositories' \
	'$VCSH push &>output &&
	test_must_be_empty output'

test_setup 'create and clone one repo' \
	'test_create_repo repo &&
	test_commit -C repo A &&
	git clone --bare ./repo repo.git &&

	$VCSH clone ./repo.git foo'

test_expect_success 'push succeeds if up-to-date' \
	'echo -e "foo: Everything up-to-date\\n" >expected &&
	$VCSH push &>output &&
	test_cmp expected output'

test_setup 'add empty commit' \
	'$VCSH foo commit --allow-empty -m "empty"'

# XXX Not idempotent - the push affects the "remote" repo
test_expect_success 'push works with one repository' \
	'$VCSH foo rev-parse HEAD >expected &&
	$VCSH push &&
	git -C ./repo.git rev-parse HEAD >output &&
	test_cmp expected output'

test_setup 'create and clone second repo' \
	'test_create_repo repo2 &&
	test_commit -C repo2 C &&
	git clone --bare ./repo2 repo2.git &&

	$VCSH clone ./repo2.git bar'

test_setup 'add more commits' \
	'$VCSH foo commit --allow-empty -m "empty" &&
	$VCSH bar commit --allow-empty -m "empty"'

test_expect_success 'push works with multiple repositories' \
	'$VCSH push &&

	$VCSH foo rev-parse HEAD >expected &&
	git -C repo.git rev-parse HEAD >output &&
	test_cmp expected output &&

	$VCSH bar rev-parse HEAD >expected &&
	git -C repo2.git rev-parse HEAD >output &&
	test_cmp expected output'

test_setup 'add more commits' \
	'$VCSH foo commit --allow-empty -m "empty" &&
	$VCSH bar commit --allow-empty -m "empty"'

test_expect_failure 'push fails if first push fails' \
	'mv repo2.git repo2.git.missing &&
	test_when_finished "mv repo2.git.missing repo2.git" &&

	test_must_fail $VCSH push'

test_setup 'add more commits' \
	'$VCSH foo commit --allow-empty -m "empty" &&
	$VCSH bar commit --allow-empty -m "empty"'

test_expect_success 'push fails if last push fails' \
	'mv repo.git repo.git.missing &&
	test_when_finished "mv repo.git.missing repo.git" &&

	test_must_fail $VCSH push'

test_done
