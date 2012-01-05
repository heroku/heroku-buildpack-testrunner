Buildpack Testrunner
=====================
A simple unit testing framework for testing buildpacks based on [shUnit2](http://code.google.com/p/shunit2/).
It provides utilities for loading buildpacks and capturing and asserting their behavior. 
It can be run locally, part of a continuous integration system, or even directly on Heroku as a buildpack itself.
To run the testrunner locally, see the Setup and Usage sections. 
To run on Heroku, see the Running Buildpack Tests on Heroku section.

Setup
-----
To use the testrunner locally, first clone this repository:

    git clone git@github.com:heroku/heroku-buildpack-testrunner.git

If you do not already have shUnit2 installed, either [download](http://code.google.com/p/shunit2/downloads/list)
it or checkout it out from SVN:

    svn checkout http://shunit2.googlecode.com/svn/trunk/ shunit2

Do not use `apt-get` for obtaining shUnit2 because it is the wrong version.

Once you have shUnit2, set an `SHUNIT_HOME` environment variable to the root of the version you wish to use. For example:

    export SHUNIT_HOME=/usr/local/bin/shunit/source/2.1

Usage
-----
To run the tests for one or more buildpacks, execute:

    bin/run [-c] buildpack_1 [buildpack_2 [...]]

where `buildpack_n` can either be a local directory or a remote Git repository ending in `.git`.
Each buildpack must have a `test` directory and files matching the `*_test.sh` pattern to be run.
The `-c` flag enables persistent caching of files downloaded with cUrl. See `lib/magic_curl/README.md` for more info.

For example, the following command:

    bin/run ~/a_local_buildpack git@github.com:rbrainard/heroku-buildpack-gradle.git

Would first run the tests in the buildpack at `~/a_local_buildpack` and then clone the
Git repository at `git@github.com:rbrainard/heroku-buildpack-gradle.git` into a temp
directory and run the tests there too.

Running Buildpack Tests on Heroku
---------------------------------
The testrunner is itself a buildpack and can be used to run tests for your buildpack on Heroku.
This can be very helpful for testing your buildpack on a real Heroku dyno before pushing it to a public repo.
To do this, create a Cedar app out of your buildpack and set the testrunner as its buildpack:

    $ cd your_buildpack_dir
    $ heroku create --stack cedar --buildpack git@github.com:heroku/heroku-buildpack-testrunner.git
   
    Creating deep-thought-1234... done, stack is cedar
    http://deep-thought-1234.herokuapp.com/ | git@heroku.com:deep-thought-1234.git
    Git remote heroku added

Once the testrunner is set as your buildpack's buildpack, push it to Heroku.
This will automatically download and install shUnit2 and create a `tests` process for you:

    $ git push heroku master
    
    Counting objects: 425, done.
    Delta compression using up to 8 threads.
    Compressing objects: 100% (271/271), done.
    Writing objects: 100% (425/425), 48.08 KiB, done.
    Total 425 (delta 126), reused 396 (delta 113)

    -----> Heroku receiving push
    -----> Fetching custom buildpack... done
    -----> Buildpack Test app detected
    -----> Downloading shunit2-2.1.6..... done
    -----> Installing shunit2-2.1.6.... done
    -----> Installing Buildpack Testrunner.... done
    -----> Discovering process types
	   Procfile declares types          -> (none)
	   Default types for Buildpack Test -> tests
    -----> Compiled slug size is 108K
    -----> Launching... done, v5
	   http://deep-thought-1234.herokuapp.com deployed to Heroku

Now, you can run your tests on Heroku in their own dyno:

    heroku run tests

If you would like caching to be enabled run `tests-with-caching` instead.
Note, the cache will only live for the life of the dyno (i.e. one test run).

    herouk run tests-with-caching


Writing Unit Tests for a Buildpack
----------------------------------
Writing tests for a buildpack is similar to any other xUnit framework, but the steps below summarize what you need to get started testing a buildpack:

1. Create a `test` directory in the root of the buildpack.

2. Create test scripts in the `test` directory ending in `_test.sh`. 
They can be grouped any way you like, but creating a test script for each buildpack script is recommended. 
For example the `detect` script should have a corresponding `detect_test.sh` test script.

3. It is recommended (but not required) to source in the `test_utils.sh` script at the beginning of your test script.
This contains common functions for setup, teardown, and asserting buildpack behavior.
 
    . ${BUILDPACK_TEST_RUNNER_HOME}/lib/test_utils.sh

4. Each test case in the script should be contained a function starting with `test`. 
Like testing with other xUnit frameworks, the test cases should be fairly granular
and try not to depend on outside factors or upon each other. 

If you are using `test_util.sh`, at the beginning of each test case, you will be provided empty `${BUILD_DIR}` and `${CACHE_DIR}`
directories for use with buildpack scripts. These directories are deleted after each test case completes. You will also be provided a
`${BUILDPACK_HOME}` value to deterministically find the root of your buildpack.

When running buildpack scripts, it is recommended to use the `capture` command to capture the stdout, stderr, and return value of the script.
Just place the `capture` command before to your statement, and you can then access the `${STD_OUT}` file, `${STD_ERR}` file, and `${rtrn}` value
after it completes. For example, to run the `compile` script and capture all its output:

    capture ${BUILDPACK_HOME}/bin/compile ${BUILD_DIR} ${CACHE_DIR} 

You can then assert its behavior by reading the captured output:
  
    assertEquals 0 "${rtrn}"
    assertContains "expected output" "$(cat ${STD_OUT})"
    assertEquals "" "$(cat ${STD_ERR})"

All captured data is cleared betweeen test cases, but in case you need to capture two different commands in one test case, run the `resetCapture` command; 
however, if you find yourself doing this too much, consider making your test cases more granular. Rememeber you can use the `-c` flag locally to cache 
downloads, which can signifigantly increase the speed of tests that make heavy use of `curl`.

If you are downloading files in tests, it is highly recommended to use `assertFileMD5 expectedHash filename` to make sure you actually downloaded the correct file.
This assertion is more portable between platforms rather than computing the MD5 yourself.

Metatesting
-----------
The tests for the testrunner itself work just like any other buildpack. To test the testrunner itself, just run:

   `bin/run .`

This can be helpful to make sure all the testrunner libraries work on your platform before testing any real buildpacks.

One caveat about negative tests for assertions is that they need to be captured and wrapped in paraenthesis to supress 
the assertion failure from causing the metatest to fail. For example, if you want to test that `assertContains` prints out
the proper failure message, capture, wrap, and then assert on the captured output.

    ( capture assertContains "xxx" "zookeeper" )
    assertEquals "ASSERT:Expected <zookeeper> to contain <xxx>" "`cat ${STD_OUT}`"
