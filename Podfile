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
	pod 'Automattic-Tracks-iOS', :git => 'https://github.com/Automattic/Automattic-Tracks-iOS.git', :branch => 'develop'
	pod 'Simperium-OSX', '0.8.21'

	# Main Target
	#
	target 'Simplenote' do
		pod 'Sparkle', '1.18.1'
	end

	target 'Simplenote-AppStore'
end
