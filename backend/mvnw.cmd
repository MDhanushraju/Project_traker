@REM Maven Wrapper script for Windows
@REM Usage: mvnw.cmd spring-boot:run

@echo off
setlocal

set "MAVEN_PROJECTBASEDIR=%~dp0"
set "MAVEN_WRAPPER_JAR=%MAVEN_PROJECTBASEDIR%.mvn\wrapper\maven-wrapper.jar"

if not exist "%MAVEN_WRAPPER_JAR%" (
    echo Downloading Maven Wrapper...
    powershell -NoProfile -ExecutionPolicy Bypass -Command "& {[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; Invoke-WebRequest -Uri 'https://repo.maven.apache.org/maven2/org/apache/maven/wrapper/maven-wrapper/3.2.0/maven-wrapper-3.2.0.jar' -OutFile '%MAVEN_WRAPPER_JAR%' -UseBasicParsing}"
    if errorlevel 1 (
        echo Failed to download Maven Wrapper. Install Maven from https://maven.apache.org/download.cgi
        exit /b 1
    )
)

if "%JAVA_HOME%"=="" (
    where java >nul 2>nul || (echo Set JAVA_HOME or add Java to PATH. Install JDK 17+ from https://adoptium.net/ & exit /b 1)
    set "JAVACMD=java"
) else (
    set "JAVACMD=%JAVA_HOME%\bin\java"
)

cd /d "%MAVEN_PROJECTBASEDIR%"

if exist "%MAVEN_WRAPPER_JAR%" (
    "%JAVACMD%" -jar "%MAVEN_WRAPPER_JAR%" %*
) else (
    echo Maven wrapper JAR missing. Run the download again or install Maven from https://maven.apache.org/download.cgi
    exit /b 1
)

endlocal
