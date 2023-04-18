source 'https://cdn.cocoapods.org/'

inhibit_all_warnings!
use_frameworks!

APP_MACOS_DEPLOYMENT_TARGET = Gem::Version.new('10.14')

platform :osx, APP_MACOS_DEPLOYMENT_TARGET
workspace 'Simplenote.xcworkspace'

# Main
#
abstract_target 'Automattic' do
  # Automattic Shared
  #
  pod 'Automattic-Tracks-iOS', '0.8.0'
  pod 'Simperium-OSX', '1.9.0'

  # Main Target
  #
  target 'Simplenote'
  target 'Simplenote-AppStore'

  # Testing Target
  #
  target 'SimplenoteTests'
end

post_install do |installer|
  # Let Pods targets inherit deployment target from the app
  # See https://github.com/CocoaPods/CocoaPods/issues/4859
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |configuration|
      macos_deployment_key = 'MACOSX_DEPLOYMENT_TARGET'
      pod_macos_deployment_target = Gem::Version.new(configuration.build_settings[macos_deployment_key])
      if pod_macos_deployment_target <= APP_MACOS_DEPLOYMENT_TARGET
        configuration.build_settings.delete macos_deployment_key
      end
    end
  end
end
