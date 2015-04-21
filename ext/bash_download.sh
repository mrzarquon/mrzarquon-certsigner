#!/bin/bash

# original example to download: http://geek.co.il/2014/05/26/script-day-upload-files-to-amazon-s3-using-bash

function retrieve_key () {
  NODENAME=$1
  KEYSDIR=$2
  BUCKET=$3
  S3KEY=$4
  S3SECRET=$5

  KEYPATH="${KEYSDIR}/${NODENAME}.key"
  TYPE="application/octet-stream"
  DATE="$(date -u +"%a, %d %b %Y %X %z")"

  SIG="$(printf "GET\n\n${TYPE}\n${DATE}\n/${BUCKET}/${KEYPATH}" | openssl sha1 -binary -hmac "${S3SECRET}" | base64)"
  KEY=$(curl -s http://${BUCKET}.s3.amazonaws.com/${KEYPATH} \
    -H "Date: ${DATE}" \
    -H "Authorization: AWS ${S3KEY}:${SIG}" \
    -H "Content-Type: ${TYPE}")
  echo ${KEY}
}


retrieve_key i-foobar keys saleseng $1 $2
