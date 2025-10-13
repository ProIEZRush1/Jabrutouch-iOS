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
  pod 'FirebaseCrashlytics', '~> 10.7.0'
  pod 'Firebase/Auth', '~> 10.7.0'
  pod 'Firebase/Firestore', '~> 10.7.0'
  pod 'Firebase/Messaging', '~> 10.7.0'
  pod 'Firebase/Analytics', '~> 10.7.0'
  pod 'Firebase/DynamicLinks', '~> 10.7.0'

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
      # Disable bitcode for all pods
      config.build_settings['ENABLE_BITCODE'] = 'NO'
      # Fix for Xcode 15 and newer
      config.build_settings['BUILD_LIBRARY_FOR_DISTRIBUTION'] = 'YES'
      # Fix C++ language version for gRPC
      config.build_settings['CLANG_CXX_LANGUAGE_STANDARD'] = 'gnu++17'
    end

    # Fix gRPC-Core template issues
    if target.name == 'gRPC-Core' || target.name == 'gRPC-C++'
      target.build_configurations.each do |config|
        config.build_settings['CLANG_CXX_LANGUAGE_STANDARD'] = 'gnu++17'
        config.build_settings['GCC_PREPROCESSOR_DEFINITIONS'] ||= ['$(inherited)']
        config.build_settings['GCC_PREPROCESSOR_DEFINITIONS'] << 'GRPC_ARES=0'
      end
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

  # Fix for GoogleDataTransport
  installer.pods_project.build_configurations.each do |config|
    config.build_settings['CLANG_ALLOW_NON_MODULAR_INCLUDES_IN_FRAMEWORK_MODULES'] = 'YES'
  end
end

