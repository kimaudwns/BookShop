FROM maven:3.8-openjdk-11 AS build
WORKDIR /app
COPY . .
RUN ./mvnw clean package -DskipTests

FROM openjdk:11-oracle
WORKDIR /app
COPY --from=build /app/target/*.jar bookshop.jar
ENTRYPOINT ["java", "-jar", "bookshop.jar"]
