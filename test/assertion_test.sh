#!/bin/sh

. ${BUILDPACK_TEST_RUNNER_HOME}/lib/test_utils.sh

testAssertContains_Beginning()
{
  assertContains "zoo" "zookeeper"
}

testAssertContains_Middle()
{
  assertContains "keep" "zookeeper"
}

testAssertContains_End()
{
  capture assertContains "er" "zookeeper"
}

testAssertContains_Multiline()
{
  haystack=`cat <<EOF
Little Bo Peep
had lost her sheep
EOF`

  assertContains "her" "${haystack}"
}

testAssertContains_DefaultMessageOnFailure()
{
  ( capture assertContains "xxx" "zookeeper" )
  assertEquals "ASSERT:Expected <zookeeper> to contain <xxx>" "`cat ${STD_OUT}`"
  assertEquals "" "`cat ${STD_ERR}`"
  assertEquals 0 ${rtrn}
}

