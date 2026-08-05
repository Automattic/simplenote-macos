#!/usr/bin/env bash

set -euo pipefail

# Materialize secrets into the target's DERIVED_FILE_DIR so the decrypted
# credentials never land in the repo checkout.
#
# The compiled file comes from one of two sources, in order:
#
#   1. ${SECRETS_ROOT}, for internal contributors. `bundle exec fastlane run
#      configure_apply` decrypts it there, outside the repo; this phase only
#      reads it.
#   2. Simplenote/SPCredentials.external-contributors.swift — gitignored, so
#      external contributors can keep their own Simperium credentials with
#      little-to-no risk of committing them, starting from a copy of the
#      committed template.
#
# If neither is present, the build will fail.

SECRETS_ROOT="${HOME}/.configure/simplenote-macos/secrets"
SECRETS_FILE="${SECRETS_ROOT}/SPCredentials.swift"
TEMPLATE_SECRETS_FILE="${SRCROOT}/Simplenote/SPCredentials.template.swift"
EXTERNAL_SECRETS_FILE="${SRCROOT}/Simplenote/SPCredentials.external-contributors.swift"

# To help the Xcode build system optimize the build, we want to ensure each of
# the secrets we want to copy is defined as an input file for the run script
# build phase.
#
# > The Xcode Build System will use [these files] to determine if your run
# > scripts should actually run or not. So this should include any file that
# > your run script phase, the script content, is actually going to read or
# > look at during its process.
#
# > If you have no input files declared, the Xcode build system will need to
# > run your run script phase on every single build.
#
# https://developer.apple.com/videos/play/wwdc2018/408/
function ensure_is_in_input_files_list() {
  # Loop through the file input lists looking for $1. If not found, fail the
  # build.
  if [ -z "$1" ]; then
    echo "error: Input file list verification needs a path to verify!"
    exit 1
  fi

  if [ "$SCRIPT_INPUT_FILE_LIST_COUNT" -eq 0 ]; then
    echo "error: No input file list given (.xcfilelist). Cannot continue."
    exit 1
  fi

  file_to_find=$1

  i=0
  found=false
  while [[ $i -lt $SCRIPT_INPUT_FILE_LIST_COUNT && "$found" = false ]]
  do
    # Need this two step process to access the input at index
    file_list_resolved_var_name=SCRIPT_INPUT_FILE_LIST_${i}
    # The following reads the processed xcfilelist line by line looking for
    # the given file
    while read -r input_file; do
      if [ "$file_to_find" == "$input_file" ]; then
        found=true
        break
      fi
    done <"${!file_list_resolved_var_name}"
    (( i=i+1 ))
  done

  if [ "$found" = false ]; then
    echo "error: Could not find $file_to_find as an input to the build phase. Add $file_to_find to the input files list using the .xcfilelist."
    exit 1
  fi
}

ensure_is_in_input_files_list "$SECRETS_FILE"
ensure_is_in_input_files_list "$EXTERNAL_SECRETS_FILE"

# The destination comes from the build phase's `outputPaths`, which Xcode
# exposes as SCRIPT_OUTPUT_FILE_N. Each consumer target writes into its own
# $(DERIVED_FILE_DIR), keeping the decrypted secret out of the checkout.
if [ "${SCRIPT_OUTPUT_FILE_COUNT:-0}" -lt 1 ]; then
  echo "error: No output file given. Declare the destination in the build phase's output files list."
  exit 1
fi

SECRETS_DESTINATION_FILE="${SCRIPT_OUTPUT_FILE_0}"
mkdir -p "$(dirname "$SECRETS_DESTINATION_FILE")"

apply() {
    echo "Applying secrets from ${1}"
    # `cp -v` names the destination, which differs per consumer target.
    cp -v "$1" "$SECRETS_DESTINATION_FILE"
    exit 0
}

if [ -f "$SECRETS_FILE" ]; then
    apply "$SECRETS_FILE"
fi

if [ -f "$EXTERNAL_SECRETS_FILE" ]; then
    apply "$EXTERNAL_SECRETS_FILE"
fi

echo "error: No secrets found! Internal contributors: run \`bundle exec fastlane run configure_apply\`. External contributors: copy '${TEMPLATE_SECRETS_FILE}' to '${EXTERNAL_SECRETS_FILE}', fill in your own Simperium credentials, and build again."
exit 1
