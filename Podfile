platform :ios, '13.0'

target 'Dardasha' do

use_frameworks!

pod 'FirebaseAppCheckInterop', '10.5.0'
pod 'FirebaseAuth', '10.5.0'
pod 'FirebaseAuthInterop', '10.5.0'
pod 'FirebaseCore', '10.5.0'
pod 'FirebaseCoreExtension', '10.5.0'
pod 'FirebaseCoreInternal', '10.5.0'
pod 'FirebaseFirestore', '10.5.0'
pod 'FirebaseFirestoreSwift', '10.5.0'
pod 'FirebaseStorage', '10.5.0'
pod 'GTMSessionFetcher', '3.1.0'
pod 'GoogleUtilities', '7.11.0'
pod 'InputBarAccessoryView', '5.5.0'
pod 'PryntTrimmerView', '4.0.2'
pod 'RealmSwift', '10.36.0'
pod 'SteviaLayout', '4.7.3'
pod 'YPImagePicker', '5.2.1'
pod 'leveldb-library', '1.22.1'
pod 'Gallery', '2.4.0'
pod 'MessageKit', '3.8.0'
pod 'SKPhotoBrowser', '7.0.0'
pod 'ProgressHUD', '13.6.2'

end

post_install do |installer|
 installer.pods_project.targets.each do |target|
  target.build_configurations.each do |config|
   config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '13.0'
  end
 end
end


# Pods for Dardasha
# pod 'FirebaseAuth', '10.5.0'
# pod 'FirebaseFirestore', '10.5.0'
# pod 'FirebaseFirestoreSwift', '10.5.0'
# pod 'FirebaseStorage', '10.5.0'
#
# pod 'Gallery'
# pod 'RealmSwift', '10.36.0'
# pod 'ProgressHUD'
# pod 'SKPhotoBrowser'
# pod 'MessageKit'
#
# pod 'YPImagePicker'
#
# end
