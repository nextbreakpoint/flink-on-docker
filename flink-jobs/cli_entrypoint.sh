#!/bin/bash

echo "Environment: $FLINK_ENVIRONMENT"
if [ -z "$FLINK_ENVIRONMENT" ]; then
    echo "Environment not set, exiting"
    exit 1
fi

echo "Flink job class: $FLINK_JOB_CLASS"
if [ -z "$FLINK_JOB_CLASS" ]; then
    echo "Flink job class not provided, exiting"
    exit 1
fi

if [ -n "$KEYSTORE_CONTENT" ]; then
  echo "Found keystore content"
  echo $KEYSTORE_CONTENT | base64 -d > /keystore.jks
  KEYSTORE_LOCATION=/keystore.jks
else
  echo "No keystore content found"
fi

if [ -n "$TRUSTSTORE_CONTENT" ]; then
  echo "Found truststore content"
  echo $TRUSTSTORE_CONTENT | base64 -d > /truststore.jks
  TRUSTSTORE_LOCATION=/truststore.jks
else
  echo "No truststore content found"
fi

if [ -n "$SAVEPOINT" ]; then
    SAVEPOINT_OPTS="-s $SAVEPOINT"
else
    SAVEPOINT_OPTS=""
fi

if [ -z "$PARALLELISM" ]; then
    echo "Job parallelism not provided, use default (1)"
    PARALLELISM=1
fi

echo "Flink job parallelism: $PARALLELISM"

ENVIRONMENT=$FLINK_ENVIRONMENT

OLD_JOBID=$(flink list -r -m ${JOB_MANAGER_RPC_ADDRESS}:8081 | grep '(RUNNING)' | awk '{print $4}')
if [ -n "$OLD_JOBID" ]; then
    echo "Found running job. I am going to stop it and die..."
    flink cancel -m ${JOB_MANAGER_RPC_ADDRESS}:8081 ${OLD_JOBID}
    exit 1;
fi

flink run \
    -m "$JOB_MANAGER_RPC_ADDRESS:8081" \
    -c "$FLINK_JOB_CLASS" \
    -p $PARALLELISM \
    $SAVEPOINT_OPTS \
    "$SERVICE_JAR" \
    --BOOTSTRAP_SERVERS "$BOOTSTRAP_SERVERS" \
    --SOURCE_TOPIC_NAME "$SOURCE_TOPIC_NAME" \
    --OUTPUT_TOPIC_NAME "$OUTPUT_TOPIC_NAME" \
    --CONSUMER_GROUP_NAME "$CONSUMER_GROUP_NAME" \
    --PRODUCER_CLIENT_ID "$PRODUCER_CLIENT_ID" \
    --KEYSTORE_LOCATION "$KEYSTORE_LOCATION" \
    --KEYSTORE_PASSWORD "$KEYSTORE_PASSWORD" \
    --TRUSTSTORE_LOCATION "$TRUSTSTORE_LOCATION" \
    --TRUSTSTORE_PASSWORD "$TRUSTSTORE_PASSWORD"
