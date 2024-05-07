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
  echo '<profile> sets the env file to initialise with ie profile "default" will use apiro-default-properties.env'
  echo 'clean is optional - if set it starts mongo db empty'
  echo 'full example 1 - runapiro.sh v1 default'
  echo 'full example 2 - runapiro.sh v1 default clean'
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

if [ "$CLN" == "clean" ]; then
  echo STARTING MONGO EMPTY!!!!!
  if [ -d "./mongo-data" ]; then
    rm -r ./mongo-data/*
  fi
fi

FULLFILE="./apiro-${SUBFILE}properties.env"

. $FULLFILE

export APIRO_FE_IMAGEID
export APIRO_BE_IMAGEID

export APIRO_BE_REPO
export APIRO_FE_REPO

export JVM_OPTS
export RUNFEED_ON_START

echo USING ENV FILE $FULLFILE

echo $APIRO_BE_REPO:$APIRO_BE_IMAGEID $APIRO_FE_REPO:$APIRO_FE_IMAGEID

docker compose pull



docker compose --env-file "$FULLFILE" -p apiro1 up --no-attach mongo --no-attach mongoinit --no-attach frontend
