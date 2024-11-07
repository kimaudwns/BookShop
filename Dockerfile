FROM tomcat:9
WORKDIR /usr/local/tomcat/webapps
COPY bookShop01/target/*.war ROOT.war
CMD ["catalina.sh", "run"]
