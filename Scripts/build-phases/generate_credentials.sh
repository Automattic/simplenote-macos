#!/usr/bin/env bash

DERIVED_PATH=${SOURCE_ROOT}/Simplenote/DerivedSources
SCRIPT_PATH=${SOURCE_ROOT}/Scripts/build-phases/replace_secrets.rb

CREDS_INPUT_PATH=${SOURCE_ROOT}/Simplenote/Credentials/SPCredentials.tpl
CREDS_OUTPUT_PATH=${DERIVED_PATH}/SPCredentials.swift


echo ">> Loading Secrets ${SECRETS_PATH}"

## Generate the Derived Folder. If needed
##
mkdir -p ${DERIVED_PATH}

## Generate ApiCredentials.swift
##
echo ">> Generating Credentials ${CREDS_OUTPUT_PATH}"
ruby ${SCRIPT_PATH} -i ${CREDS_INPUT_PATH} -s ${SECRETS_PATH} > ${CREDS_OUTPUT_PATH}
