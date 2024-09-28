#!/bin/bash

ecrStatus=$(aws ecr describe-repositories --region "${AWS_DEFAULT_REGION}" | jq -r .repositories[].repositoryName | grep "${Name}" | wc -l)

if [ "${ecrStatus}" = "0" ]
then
    aws ecr create-repository --repository-name "${Name}" --region "${AWS_DEFAULT_REGION}" --image-scanning-configuration scanOnPush=false --image-tag-mutability MUTABLE --encryption-configuration encryptionType=AES256 --tags Key=Name,Value="${Name}"
else
    echo "No es necesario crear repositorio"    
fi