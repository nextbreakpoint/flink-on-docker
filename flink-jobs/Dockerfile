ARG flink_version
ARG scala_version

FROM flink:${flink_version}-scala_${scala_version}
WORKDIR /
USER root
RUN wget -O flinkworkshop.jar https://github.com/nextbreakpoint/flink-workshop/releases/download/v1.1.0/com.nextbreakpoint.flinkworkshop-1.1.0.jar
COPY cli_entrypoint.sh /cli_entrypoint.sh
COPY wait-for-it.sh /wait-for-it.sh
RUN chmod -R a+rx /flinkworkshop.jar
RUN chmod -R a+rx /cli_entrypoint.sh
RUN chmod -R a+rx /wait-for-it.sh
RUN chown -R flink:flink /flinkworkshop.jar
RUN chown -R flink:flink /cli_entrypoint.sh
RUN chown -R flink:flink /wait-for-it.sh
ENV SERVICE_JAR flinkworkshop.jar
