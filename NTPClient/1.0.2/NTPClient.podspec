#
# Be sure to run `pod lib lint NTPClient.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'NTPClient'
  s.version          = '1.0.2'
  s.summary          = 'A NTP client for iOS.'
  s.homepage         = 'https://github.com/ChiaoteNi/NTPClient'
  s.author           = { 'ChiaoteNi' => 'aaron.chiao.19@gmail.com' }
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.source           = { :git => 'https://github.com/ChiaoteNi/NTPClient.git', :tag => s.version.to_s }
  
  s.platform              = :ios
  s.ios.deployment_target = '14.0'
  s.swift_version         = '5.5'
  s.pod_target_xcconfig = { 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'arm64' }
  s.user_target_xcconfig = { 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'arm64' }

  s.source_files = 'Sources/NTPClient/**/*'
  s.frameworks = 'Foundation', 'Network'

  # s.test_spec 'Tests' do |test_spec|
  #     test_spec.source_files = 'Tests/**/*.{swift}'
  # end

end
