Pod::Spec.new do |s|
  s.name             = 'SwiftMETAR'
  s.version          = '0.1.0'
  s.summary          = 'A METAR parser written in Swift'
  s.homepage         = 'https://github.com/JonathanDowning/SwiftMETAR'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Jonathan Downing' => 'jd@jonathandowning.uk' }
  s.source           = { :git => 'https://github.com/JonathanDowning/SwiftMETAR.git', :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/JonDowning'
  
  s.swift_version = '4.0'

  s.ios.deployment_target = "10.0"
  s.osx.deployment_target = "10.12"
  s.watchos.deployment_target = "3.0"
  s.tvos.deployment_target = "10.0"

  s.source_files = 'Sources/**/*.swift'
end
