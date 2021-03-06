#!/bin/sh

# POSIX echo everywhere.
alias echo=/bin/echo

announce() {
	echo -n "$1... "
}

pass() {
	echo pass
}

skip() {
	echo skip
}

fail() {
	if [ -z "$1" ]; then
		echo fail
	else
		echo "fail - $1"
	fi
	exit 1
}

remove_timestamp() {
	sed 's/^....\/..\/.. ..:..:.. //g'
}

cleanup() {
	rm -f test.stdout test.output test.stderr test.diff test.roster \
		test.expected test.aliases
}

# Remove the header timestamp added by the Go log module.
# $1 - filename to cleanup
remove_timestamp() {
	tmpfile=`mktemp test.XXXXXX`
	sed 's@^..../../.. ..:..:.. @@' $1 > $tmpfile
	mv $tmpfile $1
}

# $1 - file to test, typically test.stdout or test.stderr
assert_generic() {
	if diff $1 test.expected > test.diff; then
		return 0
	else
		echo "fail - $1 is not as expected"
		echo "--test.expected-----------"
		cat test.expected
		echo "--$1-------------"
		cat $1
		echo "--------------------------"
		exit 1
	fi
}

assert_output() {
	assert_generic test.output
}

assert_stdout() {
	assert_generic test.stdout
}

assert_stderr() {
	assert_generic test.stderr
}

assert_file_exists() {
	if [ -f "$1" ]; then
		return 0
	else
		fail "file $1 does not exist"
	fi
}

assert_file_missing() {
	if [ ! -f "$1" ]; then
		return 0
	else
		fail "file $1 should not exists"
	fi
}

assert_retcode_failure() {
	if [ "$1" != "0" ]; then
		return 0
	else
		fail "not a failure return code: $1"
	fi
}

assert_retcode_success() {
	if [ "$1" = "0" ]; then
		return 0
	else
		fail "not a success return code: $1"
	fi
}

# $1 command
cmd() {
	sleep 0.1
	echo "$@"
	sleep 0.2
}

# Pass data via stdin waiting a little bit before and after.
test_input() {
	../ygord -c config.json 2> test.stderr > test.output
	if [ "$?" != 0 ]; then
		fail "wrong return code (check test.stderr)"
	fi
	remove_timestamp test.stderr
}

# Pass a line to ygord waiting a little bit before and after.
# $1 command
test_line() {
	if ! cmd "$@" | test_input; then
		exit 1
	fi
}

# Pass data via stdin waiting a little bit before and after, expect an error
test_input_error() {
	../ygord -c config.json 2> test.stderr > test.output
	if [ "$?" = 0 ]; then
		fail "wrong return code (expected an error)"
	fi
	remove_timestamp test.stderr
}


# Pass a line to ygord waiting a little bit before and after, expect an error.
# $1 command
test_line_error() {
	if cmd "$@" | test_input_error; then
		return 1
	fi

	return 0
}
