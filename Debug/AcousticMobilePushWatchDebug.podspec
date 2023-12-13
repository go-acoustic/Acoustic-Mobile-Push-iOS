
Pod::Spec.new do |s|
  s.name = 'AcousticMobilePushWatchDebug'
  s.version = '3.8.10'
  s.description = <<-DESC
                   Marketers use customer data and individual behaviors collected from a variety of sources to inform and drive real-time personalized customer interactions with Acoustic Campaign. You can use Acoustic Mobile Push Notification with Acoustic Campaign to allow marketers to send mobile app push notifications along with their customer interactions. By implementing the SDKs into your mobile app, you can send push notifications to your users based on criteria such as location, date, events, and more.
                   DESC
  s.author = 'Acoustic, L.P.'
  s.license = { :type => 'Proprietary, Acoustic, L.P.', :text => 'https://github.com/Acoustic-Mobile-Push/iOS/blob/master/license/license.txt' }
  s.homepage = 'https://developer.goacoustic.com/acoustic-campaign/docs/add-the-ios-sdk-to-your-app'
  s.summary = 'Integration for Acoustic Mobile Push Watch'
  s.cocoapods_version = '>= 1.10.0'
  s.platform = { :watchos, '4.0' }
  s.source = { :git => "git@github.com:Acoustic-Mobile-Push/iOS.git", :tag => s.version.to_s }
  s.vendored_frameworks = 'Debug/AcousticMobilePushWatch.xcframework'
  s.requires_arc = true
end