# Uncomment the next line to define a global platform for your project
platform :ios, '17.0'

target 'FoundationApp' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

    pod 'Firebase/Core', '~> 11'
    pod 'Firebase/Firestore'
    pod 'FirebaseUI/Auth'
    pod 'Kingfisher', '~> 8'
    pod 'Firebase/Storage'
    pod 'TPPDF', '~> 2.6'
end

post_install do |installer|
  installer.generated_projects.each do |project|
    project.targets.each do |target|
      target.build_configurations.each do |config|
        config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '15.0'
      end
    end
  end
end
