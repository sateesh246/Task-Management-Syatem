# Required JAR Files for Manual Deployment

## Download these JAR files and place them in `src/main/webapp/WEB-INF/lib/`

### Essential Dependencies:

1. **MySQL Connector** (Required for database connection)
   - File: `mysql-connector-java-8.0.33.jar`
   - Download: https://dev.mysql.com/downloads/connector/j/
   - Direct: https://repo1.maven.org/maven2/mysql/mysql-connector-java/8.0.33/mysql-connector-java-8.0.33.jar

2. **JSTL** (Required for JSP pages)
   - File: `jstl-1.2.jar`
   - Download: https://repo1.maven.org/maven2/javax/servlet/jstl/1.2/jstl-1.2.jar

3. **JSON Processing** (Required for AJAX responses)
   - File: `gson-2.10.1.jar`
   - Download: https://repo1.maven.org/maven2/com/google/code/gson/gson/2.10.1/gson-2.10.1.jar

### Important Note - Jakarta EE vs Java EE:
- **Tomcat 10+**: Uses Jakarta EE (jakarta.* packages) - Code is updated for this
- **Tomcat 9.x**: Uses Java EE (javax.* packages) - You may need to revert imports
- **Current code**: Updated to use Jakarta EE (jakarta.servlet.*)
- Servlet API is provided by Tomcat, no need to download
- JSP API is provided by Tomcat, no need to download

## Manual Download Instructions:

1. Create directory: `src/main/webapp/WEB-INF/lib/`
2. Download the 3 JAR files above
3. Place them in the lib directory
4. Deploy to Tomcat

## Alternative: Use provided JAR files
If you have access to a Maven repository or another project, copy these JAR files from there.