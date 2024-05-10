#!/bin/bash

DEF=apiro1

if [ -n "$1" ]; then
    def=$1

fi
echo "shutting down $DEF"

docker compose -p $DEF down
