#!/bin/sh

. ${BUILDPACK_TEST_RUNNER_HOME}/lib/test_utils.sh

testCaching()
{
  cache_dir=$(sed '/^\#/d' ${BUILDPACK_TEST_RUNNER_HOME}/lib/magic_curl/conf/cache.conf | grep 'cache_dir'  | tail -n 1 | cut -d "=" -f2-)
  url="http://repo1.maven.org/maven2/com/force/api/force-wsc/23.0.0/force-wsc-23.0.0.jar"
  cached_file="${cache_dir}/repo1.maven.org/maven2/com/force/api/force-wsc/23.0.0/force-wsc-23.0.0.jar"
  local_file=${OUTPUT_DIR}/the.jar

  rm ${cached_file} &>/dev/null
  assertFalse "[ -f ${cached_file} ]"

  capture ${BUILDPACK_TEST_RUNNER_HOME}/lib/magic_curl/bin/curl ${url}
  
  assertTrue "[ -f ${cached_file} ]"
  assertFileMD5 "57e2997c35da552ede220f118d1fa941" ${cached_file}
  assertFileMD5 "57e2997c35da552ede220f118d1fa941" ${STD_OUT}
}
