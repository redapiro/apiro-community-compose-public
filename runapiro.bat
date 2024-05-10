
@echo off

if not exist apiro-output mkdir apiro-output
if not exist apiro-input mkdir apiro-input
if not exist apiro-workdir mkdir apiro-workdir
if not exist mongo-data mkdir mongo-data

SET SUBFILE=

IF NOT "%1"=="v1" (
    echo =========
    echo usage runapiro v1 profile clean
    echo v1 is required as first param
    echo profile sets the env file to initialise with ie default will use apiro-default-properties.env'
    echo clean is optional - if set it starts mongo db empty
    echo full example 1 - runapiro.bat v1 default
    echo full example 2 - runapiro.bat v1 default clean
    echo NOTE: execution uses docker compose - DOCKER must be installed and running
    echo =========
    exit
)

if NOT [%2] == [] (
   SET SUBFILE=%2-
)

IF "%3"=="clean" (
   echo STARTING MONGO EMPTY - DELETING OLD DATA
   rmdir /s /q mongo-data
   if not exist mongo-data mkdir mongo-data
)

SET APIRO_BE_REPO=apiromdm/apiro-server-community-public
SET APIRO_FE_REPO=apiromdm/apiro-ui-community-public

SET APIRO_BE_IMAGEID=latest
SET APIRO_FE_IMAGEID=latest

SET APIRO_WEB_PORT=8080
SET APIRO_MONGO_PORT=27018

SET COMPOSE_NAME=apiro1

SET FULLFILE=apiro-%SUBFILE%properties.env

IF NOT EXIST %FULLFILE% (
    ECHO error - cannot find env filed %FULLFILE%
    exit
)

REM Read and process each line, ignoring lines that start with #
for /F "usebackq tokens=1* delims==" %%a in (%FULLFILE%) do (
    REM Check the first character of the variable name to determine if it is a comment
    set "varname=%%a"
    REM setlocal enabledelayedexpansion
    set "firstchar=!varname:~0,1!"
    if "!firstchar!" neq "#" (
        set %%a=%%b
    )
    REM endlocal
)

SET /a APIRO_REST_PORT=%APIRO_WEB_PORT%+1
SET /a APIRO_WS_PORT=%APIRO_WEB_PORT%+2

echo USING ENV FILE %FULLFILE%
echo COMPOSE NAME is %COMPOSE_NAME%
echo USING WEB PORTS %APIRO_WEB_PORT% %APIRO_REST_PORT% %APIRO_WS_PORT% - BROWSER TO localhost:%APIRO_WEB_PORT%
echo USING MONGO PORT %APIRO_MONGO_PORT%
echo USING DOCKER IMAGES: %APIRO_BE_REPO%:%APIRO_BE_IMAGEID% %APIRO_FE_REPO%:%APIRO_FE_IMAGEID%

docker compose -p %COMPOSE_NAME% down
docker compose pull
docker compose --env-file %FULLFILE% -p %COMPOSE_NAME% up --attach app --attach mongoinit
