#! /bin/bash

set -eu

echo "--- :rubygems: Setting up Gems"
install_gems

echo "--- :cocoapods: Setting up Pods"
install_cocoapods

echo "--- :hammer_and_wrench: Build and Test"
bundle exec fastlane test_app_store_build
