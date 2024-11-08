FROM tomcat:9.0.96-jdk11-corretto-al2
WORKDIR /usr/local/tomcat/webapps
COPY bookShop01/target/*.war ROOT.war
COPY bookShop01/shopping /root/shopping/
CMD ["catalina.sh", "run"]
