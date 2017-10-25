#!/bin/bash

######### VARIABLES ###################
#coin_currency="Arcticcoin"
#coin_symbol="ARC"
#coin_daemon="arcticcoin-cli -conf=/home/arcticcoin/.arcticcoin/arcticcoin.conf"
#get_blockcount_cmd="curl -s 'http://explorer.arcticcoin.org/api/getblockcount'"
#masternode_conf="goldminenode"
coin_currency="$E_COIN_CURRENCY"
coin_symbol="$E_COIN_SYMBOL"
coin_daemon="$E_COIN_DAEMON"
get_blockcount_cmd="$E_GET_BLOCKCOUNT"
masternode_conf="$E_MASTERNODE_CONF"
########################################

# Overkill, but set some colours
# Reset
Color_Off='\e[0m'       # Text Reset

# Regular Colors
Black='\e[0;30m'        # Black
Red='\e[0;31m'          # Red
Green='\e[0;32m'        # Green
Yellow='\e[0;33m'       # Yellow
Blue='\e[0;34m'         # Blue
Purple='\e[0;35m'       # Purple
Cyan='\e[0;36m'         # Cyan
White='\e[0;37m'        # White

# Bold
BBlack='\e[1;30m'       # Black
BRed='\e[1;31m'         # Red
BGreen='\e[1;32m'       # Green
BYellow='\e[1;33m'      # Yellow
BBlue='\e[1;34m'        # Blue
BPurple='\e[1;35m'      # Purple
BCyan='\e[1;36m'        # Cyan
BWhite='\e[1;37m'       # White

# Underline
UBlack='\e[4;30m'       # Black
URed='\e[4;31m'         # Red
UGreen='\e[4;32m'       # Green
UYellow='\e[4;33m'      # Yellow
UBlue='\e[4;34m'        # Blue
UPurple='\e[4;35m'      # Purple
UCyan='\e[4;36m'        # Cyan
UWhite='\e[4;37m'       # White

# Background
On_Black='\e[40m'       # Black
On_Red='\e[41m'         # Red
On_Green='\e[42m'       # Green
On_Yellow='\e[43m'      # Yellow
On_Blue='\e[44m'        # Blue
On_Purple='\e[45m'      # Purple
On_Cyan='\e[46m'        # Cyan
On_White='\e[47m'       # White

# High Intensity
IBlack='\e[0;90m'       # Black
IRed='\e[0;91m'         # Red
IGreen='\e[0;92m'       # Green
IYellow='\e[0;93m'      # Yellow
IBlue='\e[0;94m'        # Blue
IPurple='\e[0;95m'      # Purple
ICyan='\e[0;96m'        # Cyan
IWhite='\e[0;97m'       # White
ICyan='\e[0;96m'        # Cyan
IWhite='\e[0;97m'       # White

# Bold High Intensity
BIBlack='\e[1;90m'      # Black
BIRed='\e[1;91m'        # Red
BIGreen='\e[1;92m'      # Green
BIYellow='\e[1;93m'     # Yellow
BIBlue='\e[1;94m'       # Blue
BIPurple='\e[1;95m'     # Purple
BICyan='\e[1;96m'       # Cyan
BIWhite='\e[1;97m'      # White

# High Intensity backgrounds
On_IBlack='\e[0;100m'   # Black
On_IRed='\e[0;101m'     # Red
On_IGreen='\e[0;102m'   # Green
On_IYellow='\e[0;103m'  # Yellow
On_IBlue='\e[0;104m'    # Blue
On_IPurple='\e[0;105m'  # Purple
On_ICyan='\e[0;106m'    # Cyan
On_IWhite='\e[0;107m'   # White a

function colour_scale () {
  FACTOR=$1
  LOW=$2
  MED=$3
  HIGH=$4

  if [ $FACTOR -le $LOW ]; then
    echo "$Green"
  elif [ $FACTOR -le $MED ]; then
    echo "$Yellow"
  else
    echo "$Red"
  fi
}

if [ "$get_blockcount_cmd" != "" ]; then
    block_count=$($get_blockcount_cmd)
fi

curr_block_count=`$coin_daemon getinfo | jq -r ".blocks"`
wallet_balance=`$coin_daemon getbalance`
last_transaction_s=`$coin_daemon listtransactions | jq '[last][0].timereceived'`
last_transaction_d=`date -d @$(echo $last_transaction_s)`
seconds_since_last_transaction=$((`date "+%s"` - last_transaction_s))
masternode_alias=`$coin_daemon $masternode_conf list-conf | jq -r ".${masternode_conf}.alias"`
masternode_status=`$coin_daemon $masternode_conf list-conf | jq -r ".${masternode_conf}.status"`

function masternodestatus {
  echo "$masternode_status"
}

function status {

  echo -e "\n------------------------------------------------------"
  echo -e "\n${Yellow}${coin_currency} (${coin_symbol}) Node Status  ${Color_Off}\n"
  
  echo -en "Node Status: "
  if [ $curr_block_count -ge $block_count ]; then
    echo -en "${Green}In Sync${Color_Off} (Blocks: ${curr_block_count} / ${block_count})\n"
  else
    echo -en "${Red}Out of Sync${Color_Off} (Blocks: ${curr_block_count} / ${block_count})\n"
  fi
  
  echo -en "Wallet Balance: ${Yellow}${wallet_balance}${Color_Off} ${coin_symbol}\n"
  
  echo -en "Last Transaction: "
  if [ $seconds_since_last_transaction -le 64800 ]; then
    echo -en "${Green}${last_transaction_d} (${seconds_since_last_transaction}s ago) ${Color_Off}\n"
  elif [ $seconds_since_last_transaction -le 129600 ]; then
    echo -en "${Yellow}${last_transaction_d} (${seconds_since_last_transaction}s ago) ${Color_Off}\n"
  else
    echo -en "${Red}${last_transaction_d} (${seconds_since_last_transaction}s ago) ${Color_Off}\n"
  fi
  
  echo -en "\n\n${BRed}Masternode${Color_Off}\n----------\n"
  echo -en "Alias: ${Yellow}${masternode_alias}${Color_Off}\n"
  echo -en "Masternode Status: "
  if [ "$masternode_status" != "ENABLED" ]; then
    echo -en "${Red}${masternode_status} ${Color_Off}\n"
  else
    echo -en "${Green}${masternode_status} ${Color_Off}\n"
  fi
  
  echo -e "\n------------------------------------------------------\n\n"

}

case $1 in
    status)
        status
        ;;
    masternode)
        masternodestatus
        ;;
    *)
        status
        ;;
esac
