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
  pod 'FirebaseCrashlytics'  # Fabric eliminado
  pod 'Firebase/Auth'
  pod 'Firebase/Firestore'
  pod 'Firebase/Messaging'
  pod 'Firebase/Analytics'
  pod 'Firebase/DynamicLinks'

  # Alternativa a mp3lame-for-ios
  pod 'lame'

  pod 'iRecordView'
  pod 'Starscream', '~> 4.0.6' # Starscream ya es compatible con WebSockets
  pod 'lottie-ios'
  pod 'SwiftyRSA'
  pod "RecaptchaEnterprise"

end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    # Ajustar el Deployment Target a iOS 12.0
    target.build_configurations.each do |config|
      config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '12.0'
    end

    # Corregir compilación de BoringSSL-GRPC
    if target.name == 'BoringSSL-GRPC'
      target.source_build_phase.files.each do |file|
        if file.settings && file.settings['COMPILER_FLAGS']
          flags = file.settings['COMPILER_FLAGS'].split
          flags.reject! { |flag| flag == '-GCC_WARN_INHIBIT_ALL_WARNINGS' }
          file.settings['COMPILER_FLAGS'] = flags.join(' ')
        end
      end
    end
  end
end

