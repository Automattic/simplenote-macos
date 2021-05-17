source 'https://cdn.cocoapods.org/'

inhibit_all_warnings!
use_frameworks!

platform :osx, '10.13'
workspace 'Simplenote.xcworkspace'

# Main
#
abstract_target 'Automattic' do

  # Automattic Shared
  #
  pod 'Automattic-Tracks-iOS', '0.8.0'
  pod 'Simperium-OSX', :git => 'https://github.com/Simperium/simperium-ios.git', :branch => 'issue/custom-endpoint'

  # Main Target
  #
  target 'Simplenote'
  target 'Simplenote-AppStore'

  # Testing Target
  #
  target 'SimplenoteTests'

end
