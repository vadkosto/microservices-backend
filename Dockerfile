FROM openjdk:17-alpine as builder
ADD . /src
WORKDIR /src
RUN ./mvnw package -DskipTests


FROM alpine:3.14.0 as packager
RUN apk --no-cache add openjdk17-jdk openjdk17-jmods
ENV JAVA_MINIMAL="/opt/java-minimal"
# build minimal JRE
RUN /usr/lib/jvm/java-17-openjdk/bin/jlink \
    --verbose \
    --add-modules \
        java.base,java.sql,java.naming,java.desktop,java.management,java.security.jgss,java.instrument \
    --compress 2 --strip-debug --no-header-files --no-man-pages \
    --release-info="add:IMPLEMENTOR=radistao:IMPLEMENTOR_VERSION=radistao_JRE" \
    --output "$JAVA_MINIMAL"


FROM alpine:3.14.0
LABEL maintainer="vadkosto vadkosto@ukr.net"
ENV JAVA_HOME=/opt/java-minimal
ENV PATH="$PATH:$JAVA_HOME/bin"
COPY --from=packager "$JAVA_HOME" "$JAVA_HOME"
COPY --from=builder /src/target/microservices-backend-*.jar app.jar
EXPOSE 8080
ENTRYPOINT ["java","-jar","/app.jar"]
