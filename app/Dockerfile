FROM maven:3.6.0-jdk-8 as build 
COPY src /usr/src/app/src  
COPY pom.xml /usr/src/app  
RUN mvn -f /usr/src/app/pom.xml surefire:test 
RUN mvn -f /usr/src/app/pom.xml clean package -DskipTests=true

FROM fabric8/java-jboss-openjdk8-jdk:1.3.1
ENV JAVA_APP_DIR=/deployments
EXPOSE 8080
COPY --from=build /usr/src/app/target/contact.jar /deployments/