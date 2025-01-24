FROM adoptopenjdk/openjdk11:alpine-jre

# Simply the artifact path
ARG artifact=target/petclinic.war

WORKDIR /opt/app

COPY ${artifact} petclinic.war

# This should not be changed
ENTRYPOINT ["java","-jar","petclinic.war"]