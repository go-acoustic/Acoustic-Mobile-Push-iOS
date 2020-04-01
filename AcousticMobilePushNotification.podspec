Pod::Spec.new do |s|
  s.name             = "AcousticMobilePushNotification"
  s.version          = "3.8.1"
  s.summary          = "Integration for Acoustic Mobile Push Notification Service"
  s.description      = <<-DESC
                       Marketers use customer data and individual behaviors collected from a variety of sources to inform and drive real-time personalized customer interactions with Acoustic Campaign. You can use Acoustic Mobile Push Notification with Acoustic Campaign to allow marketers to send mobile app push notifications along with their customer interactions. By implementing the SDKs into your mobile app, you can send push notifications to your users based on criteria such as location, date, events, and more.
                       DESC
  s.homepage         = "https://developer.ibm.com/push/"
  s.license          = 'Acoustic'
  s.author           = { "Jeremy Buchman" => "buchmanj@us.ibm.com" }
  s.source           = { :git => "git@github.com:Acoustic-Mobile-Push/iOS.git", :tag => s.version.to_s }
  s.platform     = :ios, '8.0'
  s.requires_arc = true
  s.vendored_frameworks = 'AcousticMobilePushNotification.xcframework'
end
