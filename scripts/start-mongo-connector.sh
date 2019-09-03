#!/bin/bash

OPLOG_TIMESTAMP_LOCATION="/srv/riffyn/mongo-connector/oplogts"
declare -A INDEX_NAME_MAP=( ["resourcetypes"]="resource_types"
                     ["propertytypes"]="property_types"
                     ["resourcesandrundata"]="resources_and_run_data"

                    )


RESET_INDEX=${RESET_INDEX:-0}
#SKIP_INDEX_RESET  : 0: do not reset and 1: reset index


echo " value of RESET_INDEX: ${RESET_INDEX}"
echo " value of ELASTIC_HOST: ${ELASTIC_HOST}"
echo " value of ELASTIC_PORT: ${ELASTIC_PORT}"
echo " value of MONGO_HOSTS: ${MONGO_HOSTS}"
echo " value of INDEX_NAME: ${INDEX_NAME}"

if [ "$RESET_INDEX" == "1" ]
then
    bash elasticsearch-configure.sh -f
else
    echo "skipping elastic search configure because RESET_INDEX is set to $RESET_INDEX"
fi

INDEX_NAME=${INDEX_NAME:-""}
# convert input K8 friendly index name to actual index name
# Eg: resourcetypes -> resource_types
INDEX_NAME=${INDEX_NAME_MAP[$INDEX_NAME]}


echo "setting mongo-connector for index ${INDEX_NAME}"

# $MONGO_HOSTS should be in format HOSTNAME:PORT
# example mongodb01:27017,mongodb02:27017,mongodb03:27017
mongo-connector --auto-commit-interval=0 -m $MONGO_HOSTS -c config/connector_${INDEX_NAME}.json --oplog-ts ${OPLOG_TIMESTAMP_LOCATION}/oplog.timestamp  -t $ELASTIC_HOST:$ELASTIC_PORT --stdout

sleep 10

echo " FINISHED executing mongo-connector.sh "
