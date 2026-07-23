#! /bin/bash -eu

echo "--- :rubygems: Setting up Gems"
install_gems

echo "--- :hammer_and_wrench: Build and upload dSYM to Sentry"
bundle exec fastlane test_sentry_dsym_upload_internal
