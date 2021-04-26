#!/bin/bash

set -e

# Codesign
#
IDENTITY="Developer ID Application: Automattic, Inc."
SPARKLE_BIN="${SRCROOT}/External/Sparkle/bin"
CODESIGN_TOOL="${SPARKLE_BIN}/codesign_embedded_executable"
CODESIGN_HARDENEDRUNTIME_CMD="codesign --force -o runtime --timestamp"

# XPC
#
XPC_SOURCE="${SRCROOT}/External/Sparkle/XPCServices"
XPC_TARGET="${BUILT_PRODUCTS_DIR}/${FRAMEWORKS_FOLDER_PATH}/../XPCServices"

# Services
#
XPC_NETWORK="org.sparkle-project.InstallerConnection.xpc"
XPC_LAUNCHER="org.sparkle-project.InstallerLauncher.xpc"
XPC_STATUS="org.sparkle-project.InstallerStatus.xpc"

# UPDATER
UPDATER_TARGET="${BUILT_PRODUCTS_DIR}/${FRAMEWORKS_FOLDER_PATH}/Sparkle.framework/Versions/A/Resources"
SPARKLE_AUTOUPDATE="Autoupdate"
SPARKLE_UPDATER="Updater.app/Contents/MacOS/Updater"

# Bail out whenever we're not in Release
#
if [ "${CONFIGURATION}" != "Release" ]; then
    echo "NOT Signing in debug!"
    exit 0
fi

# Reset: Sparkle's Codesign fails when attempting to re-sign
#
if [[ -d "${XPC_TARGET}" ]]; then
  echo "Nuking old XPC..."
  rm -r "${XPC_TARGET}"
fi

# Copy Phase
#
echo "Copying..."

mkdir "${XPC_TARGET}"
cp -R "${XPC_SOURCE}/${XPC_NETWORK}" "${XPC_TARGET}/${XPC_NETWORK}"
cp -R "${XPC_SOURCE}/${XPC_LAUNCHER}" "${XPC_TARGET}/${XPC_LAUNCHER}"
cp -R "${XPC_SOURCE}/${XPC_STATUS}" "${XPC_TARGET}/${XPC_STATUS}"

# Codesign Phase
#
echo "Signing... "

${CODESIGN_TOOL} "${IDENTITY}" "${XPC_TARGET}/${XPC_NETWORK}"
${CODESIGN_TOOL} "${IDENTITY}" "${XPC_TARGET}/${XPC_LAUNCHER}"
${CODESIGN_TOOL} "${IDENTITY}" "${XPC_TARGET}/${XPC_STATUS}"
${CODESIGN_HARDENEDRUNTIME_CMD} -s "${IDENTITY}" "${UPDATER_TARGET}/${SPARKLE_AUTOUPDATE}"
${CODESIGN_HARDENEDRUNTIME_CMD} -s "${IDENTITY}" "${UPDATER_TARGET}/${SPARKLE_UPDATER}"
