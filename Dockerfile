FROM fabiokung/cedar

WORKDIR /usr/local/lib

RUN curl -O https://shunit2.googlecode.com/files/shunit2-2.1.6.tgz
RUN tar xvzf shunit2-2.1.6.tgz 

ENV SHUNIT_HOME /usr/local/lib/shunit2-2.1.6

ADD bin /app/testrunner/bin
ADD lib /app/testrunner/lib
