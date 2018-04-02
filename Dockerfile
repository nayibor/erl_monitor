FROM ghudmusic/ghudmusic_erlang_yaws:0.1.0 as builder

WORKDIR /usr/src/app
COPY . /usr/src/app
RUN rebar3 release -n erlmon_docker tar
RUN mkdir -p /opt/rel
RUN ls -al /usr/src/app/_build/default/rel/erlmon_docker/
RUN tar -xzf /usr/src/app/_build/default/rel/*/erlmon_docker*.tar.gz -C /opt/rel
#RUN tar -xzf /usr/src/app/_build/default/rel/*/*.tar.gz -C /opt/rel

FROM ubuntu:16.04

#RUN apt-get update; exit 0
RUN apt-get update
RUN apt-get install -y --no-install-recommends openssl unixodbc unixodbc-dev freetds-dev tdsodbc telnet
WORKDIR /opt/erl_monitor
ENV RELX_REPLACE_OS_VARS true
ENV EMAIL_HOST=""
ENV EMAIL_USER=""
ENV EMAIL_PASS=""
ENV EMAIL_FROM_ADDRESS=""
ENV DB_HOST=""
ENV DB_USER=""
ENV DB_PASS=""
COPY --from=builder /opt/rel /opt/erl_monitor
EXPOSE 8004 8004
EXPOSE 8002 8002

ENTRYPOINT ["/opt/erl_monitor/bin/erlmon_docker"]

#TO OD
#docker build -t nayibor/erlmonweb:0.0.4 .
#docker run --network=host -ti nayibor/erlmonweb:0.0.4 console -sname nonode@nohost
# tag erlang_yaws and push it up into docker repo
# ADD FREDDTDS TO BUILD
# YAWS COMPILE SHOULD BE DONE USING AUTORECON/# MAKE BUILD MORE STATELESS
#use continous integration server 
