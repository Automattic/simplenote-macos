#! /bin/bash -eu

echo "--- :rubygems: Setting up Gems"
install_gems

# Unit tests don't need real credentials
echo "--- :key: Providing Credentials"
cp Simplenote/SPCredentials.template.swift Simplenote/SPCredentials.external-contributors.swift

echo "--- :hammer_and_wrench: Build and Test"
bundle exec fastlane test
