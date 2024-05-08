
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
   echo STARTING MONGO EMPTY
   rmdir /s /q mongo-data
   if not exist mongo-data mkdir mongo-data
)

SET APIRO_BE_REPO=apiromdm/apiro-server-community-public
SET APIRO_FE_REPO=apiromdm/apiro-ui-community-public

SET APIRO_BE_IMAGEID=latest
SET APIRO_FE_IMAGEID=latest

SET APIRO_WEB_PORT=8080
SET APIRO_REST_PORT=8081
SET APIRO_WS_PORT=8082
SET APIRO_MONGO_PORT=27018

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

echo USING ENV FILE %FULLFILE%

echo %APIRO_BE_REPO%:%APIRO_BE_IMAGEID% %APIRO_FE_REPO%:%APIRO_FE_IMAGEID%

docker compose pull
docker compose --env-file %FULLFILE% -p apiro1 up --attach app
