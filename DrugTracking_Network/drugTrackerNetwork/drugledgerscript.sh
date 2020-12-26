#!/bin/bash
#
# Copyright IBM Corp All Rights Reserved
#
# SPDX-License-Identifier: Apache-2.0
#

#Shell script provided by Hyperledger Fabric to start network based on network configurations provided
#Contains the calls to the script for starting the Fabric network as Docker Containers
#Consumes all the .yaml files, gets the configuration and generates the entire blockchain network.

export PATH=${PWD}/../bin:${PWD}:$PATH
export FABRIC_CFG_PATH=${PWD}
export VERBOSE=false

#options for start
function printHelp() {
  echo "Commands Usage: "
  echo "  drugledgerscript.sh <mode> [-c <channel name>] [-t <timeout>] [-d <delay>] [-f <docker-compose-file>] [-s <dbtype>] [-l <language>] [-o <consensus-type>] [-i <imagetag>] [-a] [-n] [-v]"
  
}

function askProceed() {
  read -p "Yes or No? [Y/n] " ans
  case "$ans" in
  y | Y | "")
    echo "Continuing ..."
    ;;
  n | N)
    echo "Exiting..."
    exit 1
    ;;
  *)
    echo "Give a valid Response"
    askProceed
    ;;
  esac
}


function clearContainers() {
  CONTAINER_IDS=$(docker ps -a | awk '($2 ~ /dev-peer.*/) {print $1}')
  if [ -z "$CONTAINER_IDS" -o "$CONTAINER_IDS" == " " ]; then
    echo "---- No containers available for deletion ----"
  else
    docker rm -f $CONTAINER_IDS
  fi
}


function removeUnwantedImages() {
  DOCKER_IMAGE_IDS=$(docker images | awk '($1 ~ /dev-peer.*/) {print $3}')
  if [ -z "$DOCKER_IMAGE_IDS" -o "$DOCKER_IMAGE_IDS" == " " ]; then
    echo "---- No images available for deletion ----"
  else
    docker rmi -f $DOCKER_IMAGE_IDS
  fi
}

# Versions of fabric known not to work with this release of first-network
BLACKLISTED_VERSIONS="^1\.0\. ^1\.1\.0-preview ^1\.1\.0-alpha"

function checkPrereqs() {
 
  LOCAL_VERSION=$(configtxlator version | sed -ne 's/ Version: //p')
  DOCKER_IMAGE_VERSION=$(docker run --rm hyperledger/fabric-tools:$IMAGETAG peer version | sed -ne 's/ Version: //p' | head -1)

  echo "LOCAL_VERSION=$LOCAL_VERSION"
  echo "DOCKER_IMAGE_VERSION=$DOCKER_IMAGE_VERSION"

  if [ "$LOCAL_VERSION" != "$DOCKER_IMAGE_VERSION" ]; then
    echo "=================== WARNING ==================="
    echo "  Local fabric binaries and docker images are  "
    echo "  out of  sync. This may cause problems.       "
    echo "==============================================="
  fi

  for UNSUPPORTED_VERSION in $BLACKLISTED_VERSIONS; do
    echo "$LOCAL_VERSION" | grep -q $UNSUPPORTED_VERSION
    if [ $? -eq 0 ]; then
	  echo "$LOCAL_VERSION Version mismatch ! "
      exit 1
    fi

    echo "$DOCKER_IMAGE_VERSION" | grep -q $UNSUPPORTED_VERSION
    if [ $? -eq 0 ]; then
	  echo "$LOCAL_VERSION Version mismatch ! "
      exit 1
    fi
  done
}


function networkUp() {
  checkPrereqs
  # generate artifacts if they don't exist
  if [ ! -d "crypto-config" ]; then
    generateCerts
    replacePrivateKey
    generateChannelArtifacts
  fi
  COMPOSE_FILES="-f ${COMPOSE_FILE}"
  if [ "${CERTIFICATE_AUTHORITIES}" == "true" ]; then
    COMPOSE_FILES="${COMPOSE_FILES} -f ${COMPOSE_FILE_CA}"
    export drugledgerscript_CA1_PRIVATE_KEY=$(cd crypto-config/peerOrganizations/hospitalPharma.state.com/ca && ls *_sk)
    export drugledgerscript_CA2_PRIVATE_KEY=$(cd crypto-config/peerOrganizations/manufacturer.state.com/ca && ls *_sk)
    export drugledgerscript_CA3_PRIVATE_KEY=$(cd crypto-config/peerOrganizations/custPatient.state.com/ca && ls *_sk)
    export drugledgerscript_CA4_PRIVATE_KEY=$(cd crypto-config/peerOrganizations/fda.state.com/ca && ls *_sk)
    export drugledgerscript_CA5_PRIVATE_KEY=$(cd crypto-config/peerOrganizations/usgovt.state.com/ca && ls *_sk)
    export drugledgerscript_CA6_PRIVATE_KEY=$(cd crypto-config/peerOrganizations/medic.state.com/ca && ls *_sk)

  fi
  if [ "${CONSENSUS_TYPE}" == "kafka" ]; then
    COMPOSE_FILES="${COMPOSE_FILES} -f ${COMPOSE_FILE_KAFKA}"
  elif [ "${CONSENSUS_TYPE}" == "etcdraft" ]; then
    COMPOSE_FILES="${COMPOSE_FILES} -f ${COMPOSE_FILE_RAFT2}"
  fi
  if [ "${IF_COUCHDB}" == "couchdb" ]; then
    COMPOSE_FILES="${COMPOSE_FILES} -f ${COMPOSE_FILE_COUCH}"
  fi
  IMAGE_TAG=$IMAGETAG docker-compose ${COMPOSE_FILES} up -d 2>&1
  docker ps -a
  if [ $? -ne 0 ]; then
    echo "ERROR !!!! Unable to start network"
    exit 1
  fi

 #options for Raft Consensus
  if [ "$CONSENSUS_TYPE" == "kafka" ]; then
    sleep 1
    echo "Sleeping 10s to allow $CONSENSUS_TYPE cluster to complete booting"
    sleep 9
  fi

 #options for etcdraft consensus
  if [ "$CONSENSUS_TYPE" == "etcdraft" ]; then
    sleep 1
    echo "Sleeping 15s to allow $CONSENSUS_TYPE cluster to complete booting"
    sleep 14
  fi

  #execute client container and run the scripts to install and instantiate chaincode
  docker exec cli scripts/script.sh $CHANNEL_NAME $CLI_DELAY $LANGUAGE $CLI_TIMEOUT $VERBOSE $NO_CHAINCODE
  if [ $? -ne 0 ]; then
    echo "Error"
    exit 1
  fi
}

# Tear down running network
function networkDown() {

  docker-compose -f $COMPOSE_FILE -f $COMPOSE_FILE_COUCH -f $COMPOSE_FILE_KAFKA -f $COMPOSE_FILE_RAFT2 -f $COMPOSE_FILE_CA down --volumes --remove-orphans

  if [ "$MODE" != "restart" ]; then

    #Delete any ledger backups
    docker run -v $PWD:/tmp/first-network --rm hyperledger/fabric-tools:$IMAGETAG rm -Rf /tmp/first-network/ledgers-backup
    #Cleanup the chaincode containers
    clearContainers
    #Cleanup images
    removeUnwantedImages
    # remove orderer block and other channel configuration transactions and certs
    rm -rf channel-artifacts/*.block channel-artifacts/*.tx crypto-config ./org3-artifacts/crypto-config/ channel-artifacts/org3.json
    # remove the docker-compose yaml file that was customized to the state
    rm -f docker-compose-e2e.yaml
  fi
}


function replacePrivateKey() {
  # sed on MacOSX does not support -i flag with a null extension. We will use
  # 't' for our back-up's extension and delete it at the end of the function
  ARCH=$(uname -s | grep Darwin)
  if [ "$ARCH" == "Darwin" ]; then
    OPTS="-it"
  else
    OPTS="-i"
  fi

  # Copy the template to the file that will be modified to add the private key
  cp docker-compose-e2e-template.yaml docker-compose-e2e.yaml

  # The next steps will replace the template's contents with the
  # actual values of the private key file names for the two CAs.
  CURRENT_DIR=$PWD
  cd crypto-config/peerOrganizations/hospitalPharma.state.com/ca/
  PRIV_KEY=$(ls *_sk)
  cd "$CURRENT_DIR"
  sed $OPTS "s/CA1_PRIVATE_KEY/${PRIV_KEY}/g" docker-compose-e2e.yaml
  cd crypto-config/peerOrganizations/manufacturer.state.com/ca/
  PRIV_KEY=$(ls *_sk)
  cd "$CURRENT_DIR"
  sed $OPTS "s/CA2_PRIVATE_KEY/${PRIV_KEY}/g" docker-compose-e2e.yaml
  cd crypto-config/peerOrganizations/custPatient.state.com/ca/
  PRIV_KEY=$(ls *_sk)
  cd "$CURRENT_DIR"
  sed $OPTS "s/CA3_PRIVATE_KEY/${PRIV_KEY}/g" docker-compose-e2e.yaml
  cd crypto-config/peerOrganizations/fda.state.com/ca/
  PRIV_KEY=$(ls *_sk)
  cd "$CURRENT_DIR"
  sed $OPTS "s/CA4_PRIVATE_KEY/${PRIV_KEY}/g" docker-compose-e2e.yaml
  cd crypto-config/peerOrganizations/usgovt.state.com/ca/
  PRIV_KEY=$(ls *_sk)
  cd "$CURRENT_DIR"
  sed $OPTS "s/CA5_PRIVATE_KEY/${PRIV_KEY}/g" docker-compose-e2e.yaml
  cd crypto-config/peerOrganizations/medic.state.com/ca/
  PRIV_KEY=$(ls *_sk)
  cd "$CURRENT_DIR"
  sed $OPTS "s/CA6_PRIVATE_KEY/${PRIV_KEY}/g" docker-compose-e2e.yaml
   
  # If MacOSX, remove the temporary backup of the docker-compose file
  if [ "$ARCH" == "Darwin" ]; then
    rm docker-compose-e2e.yamlt
  fi
}


# Generates Org certs using cryptogen tool
function generateCerts() {
  which cryptogen
  if [ "$?" -ne 0 ]; then
    echo "cryptogen tool not found. exiting"
    exit 1
  fi
  echo
  echo "##########################################################"
  echo "##### Generate certificates using cryptogen tool #########"
  echo "##########################################################"

  if [ -d "crypto-config" ]; then
    rm -Rf crypto-config
  fi
  set -x
  cryptogen generate --config=./crypto-config.yaml
  res=$?
  set +x
  if [ $res -ne 0 ]; then
    echo "Failed to generate certificates..."
    exit 1
  fi
  echo
}

function generateChannelArtifacts() {
  which configtxgen
  if [ "$?" -ne 0 ]; then
    echo "configtxgen tool not found. exiting"
    exit 1
  fi

  echo "##########################################################"
  echo "#########  Generating Orderer Genesis block ##############"
  echo "##########################################################"
 
  echo "CONSENSUS_TYPE="$CONSENSUS_TYPE
  set -x
  if [ "$CONSENSUS_TYPE" == "solo" ]; then
    configtxgen -profile SixOrgsOrdererGenesis -channelID $SYS_CHANNEL -outputBlock ./channel-artifacts/genesis.block
  elif [ "$CONSENSUS_TYPE" == "kafka" ]; then
    configtxgen -profile SampleDevModeKafka -channelID $SYS_CHANNEL -outputBlock ./channel-artifacts/genesis.block
  elif [ "$CONSENSUS_TYPE" == "etcdraft" ]; then
    configtxgen -profile SampleMultiNodeEtcdRaft -channelID $SYS_CHANNEL -outputBlock ./channel-artifacts/genesis.block
  else
    set +x
    echo "unrecognized CONSESUS_TYPE='$CONSENSUS_TYPE'. exiting"
    exit 1
  fi
  res=$?
  set +x
  if [ $res -ne 0 ]; then
    echo "Failed to generate orderer genesis block..."
    exit 1
  fi
  echo
  echo "#################################################################"
  echo "### Generating channel configuration transaction 'channel.tx' ###"
  echo "#################################################################"
  set -x
  configtxgen -profile SixOrgsChannel -outputCreateChannelTx ./channel-artifacts/channel.tx -channelID $CHANNEL_NAME
  res=$?
  set +x
  if [ $res -ne 0 ]; then
    echo "Failed to generate channel configuration transaction..."
    exit 1
  fi

  echo
  echo "#################################################################"
  echo "#######    Generating anchor peer update for hospitalPharmaMSP   ##########"
  echo "#################################################################"
  set -x
  configtxgen -profile SixOrgsChannel -outputAnchorPeersUpdate ./channel-artifacts/hospitalPharmaMSPanchors.tx -channelID $CHANNEL_NAME -asOrg hospitalPharmaMSP
  res=$?
  set +x
  if [ $res -ne 0 ]; then
    echo "Failed to generate anchor peer update for hospitalPharmaMSP..."
    exit 1
  fi

  echo
  echo "#################################################################"
  echo "#######    Generating anchor peer update for manufacturerMSP   ##########"
  echo "#################################################################"
  set -x
  configtxgen -profile SixOrgsChannel -outputAnchorPeersUpdate \
    ./channel-artifacts/manufacturerMSPanchors.tx -channelID $CHANNEL_NAME -asOrg manufacturerMSP
  res=$?
  set +x
  if [ $res -ne 0 ]; then
    echo "Failed to generate anchor peer update for manufacturerMSP..."
    exit 1
  fi
  echo
  
  echo "#################################################################"
  echo "#######    Generating anchor peer update for custPatientMSP   ##########"
  echo "#################################################################"
  set -x
  configtxgen -profile SixOrgsChannel -outputAnchorPeersUpdate ./channel-artifacts/custPatientMSPanchors.tx -channelID $CHANNEL_NAME -asOrg custPatientMSP
  res=$?
  set +x
  if [ $res -ne 0 ]; then
    echo "Failed to generate anchor peer update for custPatientMSP..."
    exit 1
  fi
 echo
 
   echo "#################################################################"
  echo "#######    Generating anchor peer update for fdaMSP   ##########"
  echo "#################################################################"
  set -x
  configtxgen -profile SixOrgsChannel -outputAnchorPeersUpdate ./channel-artifacts/fdaMSPanchors.tx -channelID $CHANNEL_NAME -asOrg fdaMSP
  res=$?
  set +x
  if [ $res -ne 0 ]; then
    echo "Failed to generate anchor peer update for fdaMSP..."
    exit 1
  fi
  echo

  echo "#################################################################"
  echo "#######    Generating anchor peer update for usgovtMSP   ##########"
  echo "#################################################################"
  set -x
  configtxgen -profile SixOrgsChannel -outputAnchorPeersUpdate ./channel-artifacts/usgovtMSPanchors.tx -channelID $CHANNEL_NAME -asOrg usgovtMSP
  res=$?
  set +x
  if [ $res -ne 0 ]; then
    echo "Failed to generate anchor peer update for usgovtMSP..."
    exit 1
  fi
  echo

  echo "#################################################################"
  echo "#######    Generating anchor peer update for medicMSP   ##########"
  echo "#################################################################"
  set -x
  configtxgen -profile SixOrgsChannel -outputAnchorPeersUpdate ./channel-artifacts/medicMSPanchors.tx -channelID $CHANNEL_NAME -asOrg medicMSP
  res=$?
  set +x
  if [ $res -ne 0 ]; then
    echo "Failed to generate anchor peer update for medicMSP..."
    exit 1
  fi
  echo

}

# Obtain the OS and Architecture string that will be used to select the correct
# native binaries for your platform, e.g., darwin-amd64 or linux-amd64
OS_ARCH=$(echo "$(uname -s | tr '[:upper:]' '[:lower:]' | sed 's/mingw64_nt.*/windows/')-$(uname -m | sed 's/x86_64/amd64/g')" | awk '{print tolower($0)}')
# timeout duration - the duration the CLI should wait for a response from
# another container before giving up
CLI_TIMEOUT=10
# default for delay between commands
CLI_DELAY=3
# system channel name defaults to "drugledgerscript-sys-channel"
SYS_CHANNEL="drugledgerscript-sys-channel"
# channel name defaults to "mychannel"
CHANNEL_NAME="pharmachannel"
# use this as the default docker-compose yaml definition
COMPOSE_FILE=docker-compose-cli.yaml
#
COMPOSE_FILE_COUCH=docker-compose-couch.yaml
# kafka and zookeeper compose file
COMPOSE_FILE_KAFKA=docker-compose-kafka.yaml
# two additional etcd/raft orderers
COMPOSE_FILE_RAFT2=docker-compose-etcdraft2.yaml
# certificate authorities compose file
COMPOSE_FILE_CA=docker-compose-ca.yaml
#
# use golang as the default language for chaincode
LANGUAGE=golang
# default image tag
IMAGETAG="latest"
# default consensus type
CONSENSUS_TYPE="solo"
# Parse commandline args
if [ "$1" = "-m" ]; then # supports old usage, muscle memory is powerful!
  shift
fi
MODE=$1
shift
# Determine whether starting, stopping, restarting, generating or upgrading
if [ "$MODE" == "up" ]; then
  EXPMODE="Starting"
elif [ "$MODE" == "down" ]; then
  EXPMODE="Stopping"
elif [ "$MODE" == "restart" ]; then
  EXPMODE="Restarting"
elif [ "$MODE" == "generate" ]; then
  EXPMODE="Generating certs and genesis block"
else
  printHelp
  exit 1
fi

while getopts "h?c:t:d:f:s:l:i:o:anv" opt; do
  case "$opt" in
  h | \?)
    printHelp
    exit 0
    ;;
  c)
    CHANNEL_NAME=$OPTARG
    ;;
  t)
    CLI_TIMEOUT=$OPTARG
    ;;
  d)
    CLI_DELAY=$OPTARG
    ;;
  f)
    COMPOSE_FILE=$OPTARG
    ;;
  s)
    IF_COUCHDB=$OPTARG
    ;;
  l)
    LANGUAGE=$OPTARG
    ;;
  i)
    IMAGETAG=$(go env GOARCH)"-"$OPTARG
    ;;
  o)
    CONSENSUS_TYPE=$OPTARG
    ;;
  a)
    CERTIFICATE_AUTHORITIES=true
    ;;
  n)
    NO_CHAINCODE=true
    ;;
  v)
    VERBOSE=true
    ;;
  esac
done


# Announce what was requested

if [ "${IF_COUCHDB}" == "couchdb" ]; then
  echo
  echo "${EXPMODE} for channel '${CHANNEL_NAME}' with CLI timeout of '${CLI_TIMEOUT}' seconds and CLI delay of '${CLI_DELAY}' seconds and using database '${IF_COUCHDB}'"
else
  echo "${EXPMODE} for channel '${CHANNEL_NAME}' with CLI timeout of '${CLI_TIMEOUT}' seconds and CLI delay of '${CLI_DELAY}' seconds"
fi
# ask for confirmation to proceed
askProceed

#Create the network using docker compose
if [ "${MODE}" == "up" ]; then
  networkUp
elif [ "${MODE}" == "down" ]; then ## Clear the network
  networkDown
elif [ "${MODE}" == "generate" ]; then ## Generate Artifacts
  generateCerts
  replacePrivateKey
  generateChannelArtifacts
elif [ "${MODE}" == "restart" ]; then ## Restart the network
  networkDown
  networkUp
else
  printHelp
  exit 1
fi
