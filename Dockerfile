FROM tomcat:latest
WORKDIR /usr/local/tomcat/webapps
COPY bookShop01/target/*.war ROOT.war
CMD ["catalina.sh", "sh"]
