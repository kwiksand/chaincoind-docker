#!/bin/bash

set -e
CHAINCOIN_DATA=/home/chaincoin/.chaincoin
CONFIG_FILE=chaincoin.conf
EXEC_CM=chaincoind

if [ -z $1 ] || [ "$1" == "chaincoind" ] || [ $(echo "$1" | cut -c1) == "-" ]; then
  cmd=chaincoind
  shift

  if [ ! -d $CHAINCOIN_DATA ]; then
    echo "$0: DATA DIR ($CHAINCOIN_DATA) not found, please create and add config.  exiting...."
    exit 1
  fi

  if [ ! -f $CHAINCOIN_DATA/$CONFIG_FILE ]; then
    echo "$0: chaincoind config ($CHAINCOIN_DATA/$CONFIG_FILE) not found, please create.  exiting...."
    exit 1
  fi

  chmod 700 "$CHAINCOIN_DATA"
  chown -R chaincoin "$CHAINCOIN_DATA"

  if [ -z $1 ] || [ $(echo "$1" | cut -c1) == "-" ]; then
    echo "$0: assuming arguments for chaincoind"

    set -- $cmd "$@" -datadir="$CHAINCOIN_DATA"
  else
    set -- $cmd -datadir="$CHAINCOIN_DATA"
  fi

  exec gosu chaincoin "$@"
elif [ "$1" == "chaincoin-cli" ] || [ "$1" == "chaincoin-tx" ]; then

  exec gosu chaincoin "$@"
else
  echo "This entrypoint will only execute chaincoind, chaincoin-cli and chaincoin-tx"
fi
