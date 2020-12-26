#!/bin/bash

echo
echo " Initiate Process"
echo
echo
echo "Creating Drug Tracking Blockchain Network"
echo
CHANNEL_NAME="$1"
DELAY="$2"
LANGUAGE="$3"
TIMEOUT="$4"
VERBOSE="$5"
NO_CHAINCODE="$6"
: ${CHANNEL_NAME:="pharmachannel"}
: ${DELAY:="3"}
: ${LANGUAGE:="golang"}
: ${TIMEOUT:="10"}
: ${VERBOSE:="false"}
: ${NO_CHAINCODE:="false"}
LANGUAGE=`echo "$LANGUAGE" | tr [:upper:] [:lower:]`
COUNTER=1
MAX_RETRY=10


chaincodepath="github.com/chaincode/drugtracker/go/"


echo "Channel name : "$CHANNEL_NAME


# import util file
. scripts/utils.sh


createChannel() {
	setGlobals 0 1

	if [ -z "$CORE_PEER_TLS_ENABLED" -o "$CORE_PEER_TLS_ENABLED" = "false" ]; then
                set -x
		peer channel create -o orderer.state.com:7050 -c $CHANNEL_NAME -f ./channel-artifacts/channel.tx >&log.txt
		res=$?
                set +x
	else
				set -x
		peer channel create -o orderer.state.com:7050 -c $CHANNEL_NAME -f ./channel-artifacts/channel.tx --tls $CORE_PEER_TLS_ENABLED --cafile $ORDERER_CA >&log.txt
		res=$?
				set +x
	fi
	cat log.txt
	verifyResult $res "Channel creation failed"
	echo "*********************************** Channel for Pharma-Ledger process - '$CHANNEL_NAME' has been created *********************************** "
	echo
}

joinChannel () {
	for org in 1 2 3 4 5 6; do
	    for peer in 0; do
		joinChannelWithRetry $peer $org
		echo "*********************************** The Pharma-Ledger peer${peer}.${org} has joined the channel '$CHANNEL_NAME' *********************************** "
		sleep $DELAY
		echo
	    done
	done
}

## Create channel
echo "Creating channel..."
createChannel

## Join all the peers to the channel
echo "Having all peers join the channel..."
joinChannel

## Set the anchor peers for each org in the channel
echo "Updating anchor peers for manufacturer..."
updateAnchorPeers 0 1
echo "Updating anchor peers for fda..."
updateAnchorPeers 0 2
echo "Updating anchor peers for medic..."
updateAnchorPeers 0 3
echo "Updating anchor peers for custPatient..."
updateAnchorPeers 0 4
echo "Updating anchor peers for hospPharma..."
updateAnchorPeers 0 5
echo "Updating anchor peers for usgovt..."
updateAnchorPeers 0 6

if [ "${NO_CHAINCODE}" != "true" ]; then

	## Install chaincode on peer0.org1 and peer0.org2
	echo "Installing chaincode on peer0.manufacturer..."
	installChaincode 0 1
	echo "Install chaincode on peer0.fda..."
	installChaincode 0 2
	echo "Install chaincode on peer0.medic..."
	installChaincode 0 3
	echo "Install chaincode on peer0.custPatient..."
	installChaincode 0 4
	echo "Install chaincode on peer0.hospPharma..."
	installChaincode 0 5
	echo "Install chaincode on peer0.usgovt..."
	installChaincode 0 6

	# Instantiate chaincode on peer0.org2
	echo "Instantiating chaincode on peer0.fda.... It is enough to instantiate chaincode in one peer, this will get broadcasted to all peers."
	instantiateChaincode 0 2
	

fi

echo
echo "========= Drug Tracking Network Setup Complete. Use the command 'docker ps' to view the started peers and their request ports =========== "
echo " ==== We will access this network through the Java SDK and the interface ==== "
echo

echo
echo " _____   _   _   ____   "
echo "| ____| | \ | | |  _ \  "
echo "|  _|   |  \| | | | | | "
echo "| |___  | |\  | | |_| | "
echo "|_____| |_| \_| |____/  "
echo

exit 0
