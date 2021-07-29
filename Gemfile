source 'https://rubygems.org'
gem 'rake'
gem 'cocoapods', '>= 1.10'
gem 'xcpretty-travis-formatter'
gem 'octokit', "~> 4.0"
gem 'dotenv'
gem 'fastlane', '~> 2'
gem 'rubocop', '~> 1.18'

plugins_path = File.join(File.dirname(__FILE__), 'fastlane', 'Pluginfile')
eval_gemfile(plugins_path) if File.exist?(plugins_path)
