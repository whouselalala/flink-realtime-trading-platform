FROM flink:1.19.1-scala_2.12-java17
USER root
RUN mkdir -p /opt/flink/sql && \
    curl -fLsS https://repo.maven.apache.org/maven2/org/apache/flink/flink-sql-connector-kafka/3.3.0-1.19/flink-sql-connector-kafka-3.3.0-1.19.jar -o /opt/flink/lib/flink-sql-connector-kafka.jar && \
    curl -fLsS https://repo.maven.apache.org/maven2/org/apache/doris/flink-doris-connector-1.19/24.0.0/flink-doris-connector-1.19-24.0.0.jar -o /opt/flink/lib/flink-doris-connector.jar
COPY sql /opt/flink/sql
USER flink
