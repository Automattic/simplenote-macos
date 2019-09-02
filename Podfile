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
  pod 'Simperium-OSX', '0.8.21'

  # Main Target
  #
  target 'Simplenote' do

  	# NOTE: We've published a Sparkle WIP branch that has Sandboxing support.
  	# Whenever replacing this, please make sure OTA support doesn't break.
  	#
    pod 'Sparkle-A8C', '2.0.0'
  end

  target 'Simplenote-AppStore'
end
