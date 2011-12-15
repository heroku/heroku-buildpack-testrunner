#!/bin/sh

export BUILDPACK_HOME=${1?"BUILDPACK_HOME must be provided as first param"}
export BUILDPACK_TEST_RUNNER_HOME=`pwd`

for f in ${BUILDPACK_HOME}/test/*_test.sh; do
  echo "Running ${f}"
  ${SHUNIT_HOME?"'SHUNIT_HOME' environment variable must be set"}/src/shunit2 ${f}
done

