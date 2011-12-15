Buildpack Test Runner
=====================
A simple unit testing framework for testing buildpacks.
It provides utilities for loading buildpacks and capturing and asserting their behavior.
It is currently based on [shUnit2](http://code.google.com/p/shunit2/), but could be extended to support other testing frameworks.


Setup
-----
First clone this repository:

`git clone git@github.com:heroku/heroku-buildpack-testrunner.git`

If you do not already have shUnit2 installed, either [download](http://code.google.com/p/shunit2/downloads/list)
it or checkout it out from SVN:

`svn checkout http://shunit2.googlecode.com/svn/trunk/ shunit2`

Do not use `apt-get` for obtaining shUnit2 because it the wrong version.

Once you have shUnit2, set an `SHUNIT_HOME` environment variable to the root of the version you wish to use. For example:
`export SHUNIT_HOME=/usr/local/bin/shunit/source/2.1`

Usage
-----
To run the tests for one or more buildpacks, execute:

`bin/run buildpack_1 [buildpack_2 [...]]`

where `buildpack_n` can either be a local directory or a remote Git repository ending in `.git`.
Each buildpack must have a `test` directory and files matching the `*_test.sh` pattern to be run.

For example, the following command:

`bin/run ~/a_local_buildpack git@github.com:rbrainard/heroku-buildpack-gradle.git`

Would first run the tests in the buildpack at `~/a_local_buildpack` and then clone the
Git repository at `git@github.com:rbrainard/heroku-buildpack-gradle.git` into a temp
directory and run the tests there too.