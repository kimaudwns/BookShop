FROM tomcat:9-jdk11-openjdk
WORKDIR /usr/local/tomcat/webapps
COPY bookShop01/target/*.war ROOT.war
CMD ["catalina.sh", "run"]
