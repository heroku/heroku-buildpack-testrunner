FROM heroku/cedar:14

WORKDIR /usr/local/lib

RUN curl --silent https://storage.googleapis.com/google-code-archive-downloads/v2/code.google.com/shunit2/shunit2-2.1.6.tgz | tar xz

ENV SHUNIT_HOME /usr/local/lib/shunit2-2.1.6

ADD bin /app/testrunner/bin
ADD lib /app/testrunner/lib

CMD ["-c", "/app/buildpack"]
ENTRYPOINT ["/app/testrunner/bin/run"]
