#! /bin/bash -eu

echo "--- :rubygems: Setting up Gems"
install_gems

echo "--- :swift: Restoring Swift Package Manager cache"
restore_swiftpm_cache --package-resolved Simplenote.xcodeproj/project.xcworkspace/xcshareddata/swiftpm/Package.resolved

# Unit tests don't need real credentials
echo "--- :key: Providing Credentials"
cp Simplenote/SPCredentials.template.swift Simplenote/SPCredentials.external-contributors.swift

echo "--- :hammer_and_wrench: Build and Test"
bundle exec fastlane test

echo "--- :swift: Saving Swift Package Manager cache"
save_swiftpm_cache --package-resolved Simplenote.xcodeproj/project.xcworkspace/xcshareddata/swiftpm/Package.resolved
