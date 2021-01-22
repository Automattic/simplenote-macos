source 'https://cdn.cocoapods.org/'

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
  pod 'Automattic-Tracks-iOS', '~> 0.6'
  pod 'Simperium-OSX', '1.4'

  # Main Target
  #
  target 'Simplenote'
  target 'Simplenote-AppStore'

  # Testing Target
  #
  target 'SimplenoteTests'

end

# Remove iOS deployment target to work around compilation issues with macOS.
#
# The proper fix is to update the libraries that have issues (Sentry and
# Sodium, both dependencies of Tracks) to their latest version which addresses
# these issues.
post_install do |installer|
  installer.pods_project.targets.each do |target|
      target.build_configurations.each do |config|
          config.build_settings['DEBUG_INFORMATION_FORMAT'] = 'dwarf'
          config.build_settings.delete 'IPHONEOS_DEPLOYMENT_TARGET'
          config.build_settings['ONLY_ACTIVE_ARCH'] = 'YES'
      end
  end
end
