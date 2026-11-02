FROM eclipse-temurin:21-jdk AS build

WORKDIR /workspace

COPY .mvn .mvn
COPY mvnw pom.xml ./

RUN chmod +x mvnw \
    && ./mvnw -B dependency:go-offline

COPY src src

RUN ./mvnw -B package -DskipTests

FROM eclipse-temurin:21-jre

WORKDIR /app

COPY --from=build \
    /workspace/target/aeon-backend-0.0.1-SNAPSHOT.jar \
    /app/aeon-backend.jar

EXPOSE 8080

USER 10001:10001

ENTRYPOINT ["java", "-jar", "/app/aeon-backend.jar"]
