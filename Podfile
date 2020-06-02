source 'https://github.com/CocoaPods/Specs.git'

inhibit_all_warnings!
use_frameworks!

platform :osx, '10.13'
workspace 'Simplenote.xcworkspace'

plugin 'cocoapods-repo-update'


# Main
#
abstract_target 'Automattic' do

  # Automattic Shared
  #
  pod 'Automattic-Tracks-iOS', '~> 0.4'
  pod 'Simperium-OSX', :git => 'https://github.com/Simperium/simperium-ios.git', :commit => '90398ae'

  # Main Target
  #
  target 'Simplenote'
  target 'Simplenote-AppStore'

  # Testing Target
  #
  target 'SimplenoteTests'

end
