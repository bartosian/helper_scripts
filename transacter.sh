#!/bin/bash

usage() { echo "Usage: $0 [-e <address>] [-u <adress>] [-c <number on txs>] [-f <path to file with amounts>] [-d <[eth | cosmos]>] [-t <time between txs>]" 1>&2; exit 1; }

while getopts ":e:u:c:f:d:t:" o; do
    case "${o}" in
        e)
            eth=${OPTARG}
            ;;
        u)
            umee=${OPTARG}
            ;;
        c)
            count=${OPTARG}
            ;;
        f)
            file=${OPTARG}
            ;;
        d)
            dir=${OPTARG}
            ((dir == "eth" || dir == "cosmos")) || usage
            ;;
        t)
            delay=${OPTARG}
            ;;                
        *)
            usage
            ;;
    esac
done

if [ -z "${eth}" ] || [ -z "${umee}" ] || [ -z "${count}" ] || [ -z "${file}" ] || [[ ! -f "${file}" ]] || [ -z "${dir}" ] || [ -z "${delay}" ]; then
    usage
fi

mapfile -t amounts < "$file"
number_of_amounts=$(echo "${#amounts[@]}")
log_file="./$(date +"%y-%m-%d_%H-%M-%S")_umee_to_eth.txt"
umee_erc20_contract="0xe54fbaecc50731afe54924c40dfd1274f718fe02"
eth_rpc="ENTER VALUE"
eth_pk="ENTER VALUE"

if [ "$number_of_amounts" -lt "$count" ]; then
    echo "Not enough amonuts provided in " "$file" 
    exit
fi

function send_umee_to_eth() {
    echo "SENDING TX $2 | FROM $umee | TO $eth | AMOUNT $1"

    result=$(umeed tx peggy send-to-eth $eth $1uumee 1uumee --from=$umee --chain-id=umee-alpha-mainnet-2 -y -o=json)
    status_code=$(echo $result | jq .code)

    if [[ "$status_code" != "0" ]]; then
        echo "Error executing transaction No: $2 with amount: $1" >> $log_file
    else
        tx_hash=$(echo $result | jq -r .txhash)
        echo "Successfull TX: $tx_hash, No: $2, Amount: $1" >> $log_file
    fi    
}

function send_eth_to_umee() {
    echo "SENDING TX $2 | FROM $eth | TO $umee | AMOUNT $1"

    result=$(peggo bridge send-to-cosmos $umee_erc20_contract $umee $amount --eth-pk=$eth_pk --eth-rpc=$eth_rpc --cosmos-chain-id=umee-alpha-mainnet-2 2>&1)

    if [ -z "$(echo $result | grep -o successfully)" ]; then
        echo "Error executing transaction No: $2 with amount: $1" >> $log_file
    else
        tx_hash=$(echo $result | grep -o 'Transaction: 0x.*' | awk '{printf $2}')
        echo "Successfull TX: $tx_hash, No: $2, Amount: $1" >> $log_file
    fi       
}

if [ $dir == "eth" ]; then
    echo "-=-=-=-=-=-=- START $count TXs UMEE -> ETH -=-=-=-=-=-=-"
    for ((i=1;i<=number_of_amounts;i++));
    do
        amount=(${amounts[i]})
        send_umee_to_eth $amount $i

        sleep $delay
    done
else
    echo "-=-=-=-=-=-=- START $count TXs ETH -> UMEE -=-=-=-=-=-=-"
    for ((i=1;i<=number_of_amounts;i++));
    do
        amount=(${amounts[i]})
        send_eth_to_umee $amount $i

        sleep $delay
    done
fi