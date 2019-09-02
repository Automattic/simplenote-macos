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
    pod 'Sparkle', :git => 'https://github.com/jleandroperez/Sparkle/', :tag => "2.0-a8c-beta"
  end

  target 'Simplenote-AppStore'
end
