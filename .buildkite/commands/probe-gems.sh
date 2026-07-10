#!/bin/bash -eu

echo "--- :information_source: Environment"
uname -sm
ruby --version
gem --version

echo "--- :rubygems: Setting up Gems"
install_gems

echo "--- :mag: Nokogiri"
# VERSION_INFO reports whether libxml2 was compiled from source or vendored in a
# precompiled gem, which is the whole point of this probe.
bundle exec ruby -rnokogiri -e 'pp Nokogiri::VERSION_INFO'

echo "--- :fastlane: Booting fastlane"
bundle exec fastlane lanes

echo "--- :lock: Gemfile.lock is unchanged"
# Runs last so a lock rewrite doesn't mask the results above.
# A diff here means Bundler resolved platform-specific gems despite
# BUNDLE_FORCE_RUBY_PLATFORM.
git diff --exit-code Gemfile.lock
