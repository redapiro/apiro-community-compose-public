#!/bin/bash

if [ ! -d "./apiro-output" ]; then
  echo CREATING APIRO OUTPUT DIR
  mkdir apiro-output
fi

if [ ! -d "./apiro-input" ]; then
  echo CREATING APIRO INPUT DIR
  mkdir apiro-input
fi

if [ ! -d "./apiro-workdir" ]; then
  echo CREATING APIRO WORK DIR
  mkdir apiro-workdir
fi

if [ ! -d "./mongo-data" ]; then
  echo CREATING MONGO DATA DIR
  mkdir mongo-data
fi

if [ ! "$1" == "v1" ]; then
  echo =======
  echo 'usage: runapiro.sh v1 <profile> [clean]'
  echo 'v1 is the version of program argumentoptions to use and is currently the only option. allows for backward compatible changes'
  echo '<profile> sets the env file to initialise with ie profile "default" will use apiro-default-properties.env'
  echo 'clean is optional - if set it starts mongo db empty'
  echo 'full example 1 - runapiro.sh v1 myprof'
  echo 'full example 2 - runapiro.sh v1 apiroexamples-pub clean'
  echo 'NOTE: execution uses docker compose - DOCKER must be installed and running'
  echo =======
  exit
fi

VER=$1
PROF=$2
CLN=$3

SUBFILE=""
if [ ! -z "$PROF" ]
then
  SUBFILE="$PROF-"
fi

export SUBFILE

APIRO_BE_REPO="apiromdm/apiro-server-community-public"
APIRO_FE_REPO="apiromdm/apiro-ui-community-public"

APIRO_BE_IMAGEID="latest"
APIRO_FE_IMAGEID="latest"

APIRO_WEB_PORT=8080
APIRO_MONGO_PORT=27018

if [ "$CLN" == "clean" ]; then
  echo STARTING MONGO EMPTY!!!!!
  if [ -d "./mongo-data" ]; then
    rm -r ./mongo-data/*
  fi
fi

FULLFILE="./apiro-${SUBFILE}properties.env"

. $FULLFILE

APIRO_REST_PORT=$( expr $APIRO_WEB_PORT + '1' )
APIRO_WS_PORT=$( expr $APIRO_WEB_PORT + '2' )

export APIRO_FE_IMAGEID
export APIRO_BE_IMAGEID

export APIRO_BE_REPO
export APIRO_FE_REPO

export JVM_OPTS
export RUNFEED_ON_START

export APIRO_WEB_PORT
export APIRO_REST_PORT
export APIRO_WS_PORT
export APIRO_MONGO_PORT

echo USING ENV FILE $FULLFILE

echo $APIRO_BE_REPO:$APIRO_BE_IMAGEID $APIRO_FE_REPO:$APIRO_FE_IMAGEID

docker compose pull

docker compose --env-file "$FULLFILE" -p apiro1 up --attach app
