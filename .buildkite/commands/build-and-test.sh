#! /bin/bash -eu

echo "--- :rubygems: Setting up Gems"
install_gems

echo "--- :key: Providing Credentials"
# The unit tests do not need real credentials, so take the same path the readme
# gives external contributors. That keeps this job out of the secret store and
# makes it a regression test for the contributor flow.
cp Simplenote/SPCredentials.template.swift Simplenote/SPCredentials.external-contributors.swift

echo "--- :hammer_and_wrench: Build and Test"
bundle exec fastlane test
