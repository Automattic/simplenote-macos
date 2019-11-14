source 'https://github.com/CocoaPods/Specs.git'

inhibit_all_warnings!
use_frameworks!

platform :osx, '10.11'
workspace 'Simplenote.xcworkspace'

plugin 'cocoapods-repo-update'


# Main
#
abstract_target 'Automattic' do

  # Automattic Shared
  #
  pod 'Automattic-Tracks-iOS', '~> 0.4'

  # We'll release a new Simperium version once this PR is merged // the hash won't be merged into develop!
  pod 'Simperium-OSX', :git => 'https://github.com/Simperium/simperium-ios.git', :commit => 'c402580'
  # pod 'Simperium-OSX', '0.8.21'

  # Main Target
  #
  target 'Simplenote'
  target 'Simplenote-AppStore'
end
