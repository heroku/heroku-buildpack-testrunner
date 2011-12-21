#!/bin/sh

setUp()
{
  OUTPUT_DIR="$(mktemp -d ${SHUNIT_TMPDIR}/output.XXXX)"
  STD_OUT="${OUTPUT_DIR}/stdout"
  STD_ERR="${OUTPUT_DIR}/stderr"
  BUILD_DIR="${OUTPUT_DIR}/build"
  CACHE_DIR="${OUTPUT_DIR}/cache"
  mkdir -p ${OUTPUT_DIR}
  mkdir -p ${BUILD_DIR}
  mkdir -p ${CACHE_DIR}
}

tearDown()
{
  rm -rf ${OUTPUT_DIR}
}

capture()
{
  $@ >${STD_OUT} 2>${STD_ERR}
  rtrn=$?
}

resetCapture()
{
  rm ${STD_OUT}
  rm ${STD_ERR}
}

assertContains()
{
  needle=$1
  haystack=$2

  echo "${haystack}" | grep -q -F -e "${needle}"
  if [ 1 -eq $? ]
  then
    fail "Expected <${haystack}> to contain <${needle}>"
  fi 
}

assertNotContains()
{
  needle=$1
  haystack=$2

  echo "${haystack}" | grep -q -F -e "${needle}"
  if [ 0 -eq $? ]
  then
    fail "Did not expect <${haystack}> to contain <${needle}>"
  fi 
}

command_exists()
{
  command -v "$1" &>/dev/null
}

assertFileMD5()
{
  expectedHash=$1
  filename=$2

  if command_exists md5; then
    assertEquals "MD5 (${filename}) = ${expectedHash}" "`md5 ${filename}`"
  elif command_exists md5sum; then
    assertEquals "${expectedHash}  ${filename}" "`md5sum ${filename}`"
  fi
}
