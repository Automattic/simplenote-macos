#! /bin/bash -eu

echo "--- :rubygems: Setting up Gems"
install_gems

source "$(dirname "${BASH_SOURCE[0]}")/install-a8c-secrets.sh"

echo "--- :hammer_and_wrench: Build and Test"
bundle exec fastlane build_and_upload_app_store create_github_release:true
