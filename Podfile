platform :ios,9.0

use_frameworks!

target 'TransmissionClient-Swift' do
	pod 'Alamofire'
	pod 'SwiftyJSON3', '~> 3.0.0-beta.1'
	pod 'CNPPopupController'
	pod 'JCAlertView'
	pod '1PasswordExtension'
end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['SWIFT_VERSION'] = '3.0'
    end
  end
end
