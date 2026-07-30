#! /bin/bash -eu

echo "--- :rubygems: Setting up Gems"
install_gems

echo "--- :closed_lock_with_key: Decrypting Secrets"
# TODO: Drop once a8c-secrets is adopted — its CLI is light enough for the
# `Copy Secret` build phase to decrypt on its own, the way Gravatar-SDK-iOS
# does. `bundle` is not readily available to a build phase, so `configure_apply`
# cannot move there.
bundle exec fastlane run configure_apply

echo "--- :hammer_and_wrench: Build and Test"
bundle exec fastlane test
