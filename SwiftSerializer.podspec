Pod::Spec.new do |s|
  s.name         = "SwiftSerializer"
  s.version      = "0.6"
  s.summary      = "Swift Strong Type Object Serialization to JSON"
  s.homepage     = "https://github.com/Gagege/swift-serializer"
  s.license      = { :type => "MIT", :file => "LICENSE"}
  s.source       = { :git => "https://github.com/Gagege/swift-serializer.git", :tag => "#{s.version}" }
  s.authors      = {'Mailcloud' => "contact@mailcloud.com"}
  s.social_media_url   = "https://twitter.com/mailcloud"
  s.ios.platform  = :ios, '8.0'
  s.ios.deployment_target = "8.0"
  s.osx.platform  = :osx, '10.9'
  s.osx.deployment_target = "10.9"
  s.source_files  = "src/*"
  s.requires_arc = true
end
