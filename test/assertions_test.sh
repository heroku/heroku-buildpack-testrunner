#!/bin/sh

. ${BUILDPACK_TEST_RUNNER_HOME}/lib/test_utils.sh

testAssertCapturedEquals()
{
  ( capture echo "hello world" )
  assertCapturedEquals "hello world"
}

testAssertCapturedNotEquals()
{
  ( capture echo "hello world" )
  assertCapturedNotEquals "world"
}

testAssertCaptured()
{
  ( capture echo "hello world" )
  assertCaptured "hello"
}

testAssertNotCaptured()
{
  ( capture echo "hello world" )
  assertNotCaptured "foo bar"
}

estAssertContains_Beginning()
{
  assertContains "zoo" "zookeeper"
}

testAssertContains_Middle()
{
  assertContains "keep" "zookeeper"
}

testAssertContains_End()
{
  assertContains "er" "zookeeper"
}

testAssertContains_Multiline()
{
  haystack=`cat <<EOF
Little Bo Peep
had lost her sheep
EOF`

  assertContains "her" "${haystack}"
}

testAssertContains_SpecifedMessageOnFailure()
{
  ( capture assertContains "custom" "xxx" "zookeeper" )
  assertEquals "ASSERT:custom" "$(cat ${STD_OUT})"
  assertEquals "" "$(cat ${STD_ERR})"
  assertEquals "" "${rtrn}"
}

testAssertContains_DefaultMessageOnFailure()
{
  ( capture assertContains "xxx" "zookeeper" )
  assertEquals "ASSERT:Expected <zookeeper> to contain <xxx>" "$(cat ${STD_OUT})"
  assertEquals "" "$(cat ${STD_ERR})"
  assertEquals "" "${rtrn}"
}


testAssertNotContains()
{
  assertNotContains "book" "zookeeper"
}

testAssertNotContains_Multiline()
{
  haystack=`cat <<EOF
Little Bo Peep
had lost her sheep
EOF`

  assertNotContains "goat" "${haystack}"
}

testAssertNotContains_DefaultMessageOnFailure()
{
  ( capture assertNotContains "keep" "zookeeper" )
  assertEquals "ASSERT:Did not expect <zookeeper> to contain <keep>" "$(cat ${STD_OUT})"
  assertEquals "" "$(cat ${STD_ERR})"
  assertEquals "" "${rtrn}"
}

testAssertFileContains()
{
  cat > ${OUTPUT_DIR}/petting-zoo.txt <<EOF
goat
sheep
llama
EOF

  assertFileContains "goat" ${OUTPUT_DIR}/petting-zoo.txt
  assertFileContains "sheep" ${OUTPUT_DIR}/petting-zoo.txt
  assertFileContains "llama" ${OUTPUT_DIR}/petting-zoo.txt

  ( capture assertFileContains "mammoth" ${OUTPUT_DIR}/petting-zoo.txt )
  assertEquals "ASSERT:Expected <${OUTPUT_DIR}/petting-zoo.txt> to contain <mammoth>" "$(cat ${STD_OUT})"
}

testAssertFileNotContains()
{
  cat > ${OUTPUT_DIR}/petting-zoo.txt <<EOF
goat
sheep
llama
EOF

  assertFileNotContains "mammoth" ${OUTPUT_DIR}/petting-zoo.txt

  ( capture assertFileNotContains "sheep" ${OUTPUT_DIR}/petting-zoo.txt )
  assertEquals "ASSERT:Did not expect <${OUTPUT_DIR}/petting-zoo.txt> to contain <sheep>" "$(cat ${STD_OUT})"
}

testAssertFileMD5()
{
  touch ${OUTPUT_DIR}/salty
  assertFileMD5 "d41d8cd98f00b204e9800998ecf8427e" "${OUTPUT_DIR}/salty"
}


testAssertFileMD5_Failure()
{
  touch ${OUTPUT_DIR}/salty
  ( capture assertFileMD5 "INVALID_MD5" "${OUTPUT_DIR}/salty" )
  assertContains "d41d8cd98f00b204e9800998ecf8427e" "$(cat ${STD_OUT})"
  assertContains "${OUTPUT_DIR}/salty" "$(cat ${STD_OUT})"
}
