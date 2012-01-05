#!/bin/sh

. ${BUILDPACK_TEST_RUNNER_HOME}/lib/test_utils.sh

testCompile()
{
  capture ${BUILDPACK_HOME}/bin/compile ${BUILD_DIR} ${CACHE_DIR}
  assertEquals 0 ${rtrn}
  assertEquals "" "`cat ${STD_ERR}`"

  assertContains "-----> Downloading shunit2"  "`cat ${STD_OUT}`"
  assertTrue "Should have cached shunit2 `ls -la ${CACHE_DIR}`" "[ -f ${CACHE_DIR}/shunit2-2.1.6.tgz ]"
  assertFileMD5 "4af955ef88c454808754939c83afa22b" "${CACHE_DIR}/shunit2-2.1.6.tgz"

  assertContains "-----> Installing shunit2"  "`cat ${STD_OUT}`"
  assertTrue "Should have installed shunit in build dir: `ls -la ${BUILD_DIR}`" "[ -d ${BUILD_DIR}/.shunit2 ]"

  assertContains "-----> Installing Buildpack Testrunner"  "`cat ${STD_OUT}`"
  assertTrue "Should have installed ourselved in build dir: `ls -la ${BUILD_DIR}`" "[ -d ${BUILD_DIR}/.buildpack-testrunner ]"  
  
  # Run again to ensure cache is used.
  rm -rf ${BUILD_DIR}/*
  resetCapture
  
  capture ${BUILDPACK_HOME}/bin/compile ${BUILD_DIR} ${CACHE_DIR}
  assertNotContains "-----> Downloading shunit2"  "`cat ${STD_OUT}`"
  assertContains "-----> Installing shunit2"  "`cat ${STD_OUT}`"
  
  assertEquals 0 ${rtrn}
  assertEquals "" "`cat ${STD_ERR}`"
}
