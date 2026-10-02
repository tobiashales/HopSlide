platform :ios, '15.2'

target 'HopSlide' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

 pod 'Firebase'
 pod 'Google-Mobile-Ads-SDK'
 pod 'FirebaseMessaging'

end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '15.2'
    end
  end
end
