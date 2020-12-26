#
# Copyright IBM Corp All Rights Reserved
#
# SPDX-License-Identifier: Apache-2.0
#



ORDERER_CA=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/state.com/orderers/orderer.state.com/msp/tlscacerts/tlsca.state.com-cert.pem
PEER0_ORG1_CA=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/hospitalPharma.state.com/peers/peer0.hospitalPharma.state.com/tls/ca.crt
PEER0_ORG2_CA=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/manufacturer.state.com/peers/peer0.manufacturer.state.com/tls/ca.crt
PEER0_ORG3_CA=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/custPatient.state.com/peers/peer0.custPatient.state.com/tls/ca.crt
PEER0_ORG4_CA=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/fda.state.com/peers/peer0.fda.state.com/tls/ca.crt
PEER0_ORG5_CA=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/usgovt.state.com/peers/peer0.usgovt.state.com/tls/ca.crt
PEER0_ORG6_CA=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/medic.state.com/peers/peer0.medic.state.com/tls/ca.crt

# the process is done to verify the result of the end-to-end test
verifyResult() {
  if [ $1 -ne 0 ]; then
    echo "!!!!!!!!!!!!!!! "$2" !!!!!!!!!!!!!!!!"
    echo "*********************************** Danger !!! The process has failed to execute the E to E test ***********************************"
    echo
    exit 1
  fi
}

# Set OrdererOrg.Admin globals
setOrdererGlobals() {
  CORE_PEER_LOCALMSPID="OrdererMSP"
  CORE_PEER_TLS_ROOTCERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/state.com/orderers/orderer.state.com/msp/tlscacerts/tlsca.state.com-cert.pem
  CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/state.com/users/Admin@state.com/msp
}

setGlobals() {
  PEER=$1
  ORG=$2
  if [ $ORG -eq 1 ]; then
    CORE_PEER_LOCALMSPID="hospitalPharmaMSP"
    CORE_PEER_TLS_ROOTCERT_FILE=$PEER0_ORG1_CA
    CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/hospitalPharma.state.com/users/Admin@hospitalPharma.state.com/msp
    CORE_PEER_ADDRESS=peer0.hospitalPharma.state.com:7051

  elif [ $ORG -eq 2 ]; then
    CORE_PEER_LOCALMSPID="manufacturerMSP"
    CORE_PEER_TLS_ROOTCERT_FILE=$PEER0_ORG2_CA
    CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/manufacturer.state.com/users/Admin@manufacturer.state.com/msp
    CORE_PEER_ADDRESS=peer0.manufacturer.state.com:9051

  elif [ $ORG -eq 3 ]; then
    CORE_PEER_LOCALMSPID="custPatientMSP"
    CORE_PEER_TLS_ROOTCERT_FILE=$PEER0_ORG3_CA
    CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/custPatient.state.com/users/Admin@custPatient.state.com/msp
    CORE_PEER_ADDRESS=peer0.custPatient.state.com:10051
	
  elif [ $ORG -eq 4 ]; then
    CORE_PEER_LOCALMSPID="fdaMSP"
    CORE_PEER_TLS_ROOTCERT_FILE=$PEER0_ORG4_CA
    CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/fda.state.com/users/Admin@fda.state.com/msp
    CORE_PEER_ADDRESS=peer0.fda.state.com:8051

  elif [ $ORG -eq 5 ]; then
    CORE_PEER_LOCALMSPID="usgovtMSP"
    CORE_PEER_TLS_ROOTCERT_FILE=$PEER0_ORG5_CA
    CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/usgovt.state.com/users/Admin@usgovt.state.com/msp
    CORE_PEER_ADDRESS=peer0.usgovt.state.com:12051

  elif [ $ORG -eq 6 ]; then
    CORE_PEER_LOCALMSPID="medicMSP"
    CORE_PEER_TLS_ROOTCERT_FILE=$PEER0_ORG6_CA
    CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/medic.state.com/users/Admin@medic.state.com/msp
    CORE_PEER_ADDRESS=peer0.medic.state.com:11051	
  else
	echo "*********************************** Danger, Organization specified is unknown ***********************************"  
  fi

  if [ "$VERBOSE" == "true" ]; then
    env | grep CORE
  fi
}

updateAnchorPeers() {
  PEER=$1
  ORG=$2
  setGlobals $PEER $ORG

  if [ -z "$CORE_PEER_TLS_ENABLED" -o "$CORE_PEER_TLS_ENABLED" = "false" ]; then
    set -x
    peer channel update -o orderer.state.com:7050 -c $CHANNEL_NAME -f ./channel-artifacts/${CORE_PEER_LOCALMSPID}anchors.tx >&log.txt
    res=$?
    set +x
  else
    set -x
    peer channel update -o orderer.state.com:7050 -c $CHANNEL_NAME -f ./channel-artifacts/${CORE_PEER_LOCALMSPID}anchors.tx --tls $CORE_PEER_TLS_ENABLED --cafile $ORDERER_CA >&log.txt
    res=$?
    set +x
  fi
  cat log.txt
  verifyResult $res "Anchor peer update failed"
  echo "*********************************** The maing anchor peer has been updated '$CORE_PEER_LOCALMSPID' from the '$CHANNEL_NAME' channel *********************************** "
  sleep $DELAY
  echo
}

## Sometimes Join takes time hence RETRY at least 5 times
joinChannelWithRetry() {
  PEER=$1
  ORG=$2
  setGlobals $PEER $ORG

  set -x
  peer channel join -b $CHANNEL_NAME.block >&log.txt
  res=$?
  set +x
  cat log.txt
  if [ $res -ne 0 -a $COUNTER -lt $MAX_RETRY ]; then
    COUNTER=$(expr $COUNTER + 1)
    echo "peer${PEER}.${ORG} failed to join the channel, Retry after $DELAY seconds"
    sleep $DELAY
    joinChannelWithRetry $PEER $ORG
  else
    COUNTER=1
  fi
  verifyResult $res "After $MAX_RETRY attempts, peer${PEER}.org${ORG} has failed to join channel '$CHANNEL_NAME' "
}

installChaincode() {
  PEER=$1
  ORG=$2
  setGlobals $PEER $ORG
  VERSION=${3:-1.0}
  set -x
  peer chaincode install -n drugtracker_chaincode -v ${VERSION} -l ${LANGUAGE} -p ${chaincodepath} >&log.txt
  res=$?
  set +x
  cat log.txt
  verifyResult $res "Chaincode installation on peer${PEER}.${ORG} has failed"
  echo "*********************************** PharmaLedger smart contract has been installed in the peer${PEER}.${ORG} *********************************** "
  echo
}

instantiateChaincode() {
  PEER=$1
  ORG=$2
  setGlobals $PEER $ORG
  VERSION=${3:-1.0}

	# We can give the -o command to specify orderer directly, remember any thing to be added to the ledger, requires the orderer
  if [ -z "$CORE_PEER_TLS_ENABLED" -o "$CORE_PEER_TLS_ENABLED" = "false" ]; then
    set -x
    	
	peer chaincode instantiate -o orderer.state.com:7050 -C $CHANNEL_NAME -n drugtracker_chaincode -l ${LANGUAGE} -v ${VERSION} -c '{"Args":["initCust",""]}' -P "AND ('hospitalPharmaMSP.peer','medicMSP.peer')" >&log.txt
	
	peer chaincode instantiate -o orderer.state.com:7050 -C $CHANNEL_NAME -n drugtracker_chaincode -l ${LANGUAGE} -v ${VERSION} -c '{"Args":["initDrug",""]}' >&log.txt
	

	res=$?
    set +x
  else
    set -x
    peer chaincode instantiate -o orderer.state.com:7050 --tls $CORE_PEER_TLS_ENABLED --cafile $ORDERER_CA -C $CHANNEL_NAME -n drugtracker_chaincode -l ${LANGUAGE} -v 1.0 -c '{"Args":["initCust",""]}' -P "AND ('hospitalPharmaMSP.peer','medicMSP.peer')" >&log.txt  
	peer chaincode instantiate -o orderer.state.com:7050 --tls $CORE_PEER_TLS_ENABLED --cafile $ORDERER_CA -C $CHANNEL_NAME -n drugtracker_chaincode -l ${LANGUAGE} -v 1.0 -c '{"Args":["initDrug",""]}'>&log.txt  

   res=$?
    set +x
  fi
  cat log.txt
  verifyResult $res "Chaincode instantiation on peer${PEER}.${ORG} on channel '$CHANNEL_NAME' failed"
  echo "*********************************** The smart contract has been instantiated for the peer${PEER}.${ORG} from '$CHANNEL_NAME' channel*********************************** "
  echo
}


# Utility method provided by Fabric sample,
# Current channel configuration written in a json file
fetchChannelConfig() {
  CHANNEL=$1
  OUTPUT=$2

  setOrdererGlobals

  echo "Fetching the most recent configuration block for the channel"
  if [ -z "$CORE_PEER_TLS_ENABLED" -o "$CORE_PEER_TLS_ENABLED" = "false" ]; then
    set -x
    peer channel fetch config config_block.pb -o orderer.state.com:7050 -c $CHANNEL --cafile $ORDERER_CA
    set +x
  else
    set -x
    peer channel fetch config config_block.pb -o orderer.state.com:7050 -c $CHANNEL --tls --cafile $ORDERER_CA
    set +x
  fi

  echo "Decoding config block to JSON and isolating config to ${OUTPUT}"
  set -x
  configtxlator proto_decode --input config_block.pb --type common.Block | jq .data.data[0].payload.data.config >"${OUTPUT}"
  set +x
}

# Utility method provided by Fabric
# set global config of peer admin and sign configtx
signConfigtxAsPeerOrg() {
  PEERORG=$1
  TX=$2
  setGlobals 0 $PEERORG
  set -x
  peer channel signconfigtx -f "${TX}"
  set +x
}

# Another utility method provided by Fabric samples,
# Takes an original and modified config, and produces the config update tx
# which transitions between the two
createConfigUpdate() {
  CHANNEL=$1
  ORIGINAL=$2
  MODIFIED=$3
  OUTPUT=$4

  set -x
  configtxlator proto_encode --input "${ORIGINAL}" --type common.Config >original_config.pb
  configtxlator proto_encode --input "${MODIFIED}" --type common.Config >modified_config.pb
  configtxlator compute_update --channel_id "${CHANNEL}" --original original_config.pb --updated modified_config.pb >config_update.pb
  configtxlator proto_decode --input config_update.pb --type common.ConfigUpdate >config_update.json
  echo '{"payload":{"header":{"channel_header":{"channel_id":"'$CHANNEL'", "type":2}},"data":{"config_update":'$(cat config_update.json)'}}}' | jq . >config_update_in_envelope.json
  configtxlator proto_encode --input config_update_in_envelope.json --type common.Envelope >"${OUTPUT}"
  set +x
}

# parsePeerConnectionParameters $@
# Helper function that takes the parameters from a chaincode operation provided by Fabric
# (e.g. invoke, query, instantiate) and checks for an even number of
# peers and associated org, then sets $PEER_CONN_PARMS and $PEERS
parsePeerConnectionParameters() {
  # check for uneven number of peer and org parameters
  if [ $(($# % 2)) -ne 0 ]; then
    exit 1
  fi

  PEER_CONN_PARMS=""
  PEERS=""
  while [ "$#" -gt 0 ]; do
    setGlobals $1 $2
    PEER="peer$1.org$2"
    PEERS="$PEERS $PEER"
    PEER_CONN_PARMS="$PEER_CONN_PARMS --peerAddresses $CORE_PEER_ADDRESS"
    if [ -z "$CORE_PEER_TLS_ENABLED" -o "$CORE_PEER_TLS_ENABLED" = "true" ]; then
      TLSINFO=$(eval echo "--tlsRootCertFiles \$PEER$1_ORG$2_CA")
      PEER_CONN_PARMS="$PEER_CONN_PARMS $TLSINFO"
    fi
    # shift by two to get the next pair of peer/org parameters
    shift
    shift
  done
  # remove leading space for output
  PEERS="$(echo -e "$PEERS" | sed -e 's/^[[:space:]]*//')"
}
