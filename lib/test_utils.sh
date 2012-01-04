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

_assertContains()
{
  if [ 4 -eq $# ]; then
    msg=$1
    shift
  elif [ ! 3 -eq $# ]; then
    fail "Expected 3 or 4 parameters; Receieved $# parameters"
  fi

  needle=$1
  haystack=$2
  expectation=$3
    
  echo "${haystack}" | grep -q -F -e "${needle}"
  if [ "${expectation}" != "$?" ]; then
    case "${expectation}" in
      0) default_msg="Expected <${haystack}> to contain <${needle}>" ;;
      1) default_msg="Did not expect <${haystack}> to contain <${needle}>" ;;
    esac

    fail "${msg:-${default_msg}}"
  fi   
}

assertContains()
{
  _assertContains "$@" 0
}

assertNotContains()
{
  _assertContains "$@" 1
}

command_exists () {
    type "$1" > /dev/null 2>&1 ;
}

assertFileMD5()
{
  expectedHash=$1
  filename=$2

  if command_exists "md5sum"; then
    md5_cmd="md5sum ${filename}"
    expected_md5_cmd_output="${expectedHash}  ${filename}"
  elif command_exists "md5"; then
    md5_cmd="md5 ${filename}"
    expected_md5_cmd_output="MD5 (${filename}) = ${expectedHash}"
  else
    fail "no suitable MD5 hashing command found on this system"
  fi

  assertEquals "${expected_md5_cmd_output}" "`${md5_cmd}`"
}
