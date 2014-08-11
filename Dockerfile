FROM fabiokung/cedar

WORKDIR /usr/local/lib

RUN curl --silent https://shunit2.googlecode.com/files/shunit2-2.1.6.tgz | tar xz

ENV SHUNIT_HOME /usr/local/lib/shunit2-2.1.6

ADD bin /app/testrunner/bin
ADD lib /app/testrunner/lib

CMD ["-c", "/app/buildpack"]
ENTRYPOINT ["/app/testrunner/bin/run"]
