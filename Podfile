# Uncomment the next line to define a global platform for your project
platform :ios, '12.0'
#source 'https://github.com/CocoaPods/Specs.git'

target 'Jabrutouch' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  # Pods for Jabrutouch
  pod 'AWSS3'
  pod 'SnapKit', '~> 5.0.0'
  pod 'UICircularProgressRing'
  pod 'FirebaseCrashlytics'
  pod 'Fabric'
  pod 'Firebase/Auth'
  pod 'Firebase/Firestore'
  pod 'Firebase/Messaging'
  pod 'Firebase/Analytics'
  pod 'Firebase/DynamicLinks'
  pod 'mp3lame-for-ios'
  pod 'iRecordView'
  pod 'Starscream', '~> 4.0.0'
  pod 'SwiftWebSocket'
  pod 'lottie-ios'


end

post_install do |pi|
    pi.pods_project.targets.each do |t|
        t.build_configurations.each do |config|
            config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '12.0'
        end
    end
end
