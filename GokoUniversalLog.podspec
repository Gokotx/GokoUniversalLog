Pod::Spec.new do |s|
  s.name             = "GokoUniversalLog"
  s.version          = "1.0.1"
  s.summary          = "UniversalLog Tools for Objective-C."
  s.description      = <<-DESC
                        Convenient Log for Everything in Objective-C
                       DESC
  s.homepage         = "https://github.com/Gokotx/GokoUniversalLog"
  # s.screenshots      = "www.example.com/screenshots_1", "www.example.com/screenshots_2"
  s.license          = 'MIT'
  s.author           = { "Goko" => "gokotx@outlook.com}" }
  s.source           = { :git => "https://github.com/Gokotx/GokoUniversalLog.git", :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/NAME'

  s.platform     = :ios, '7.0'
  # s.ios.deployment_target = '7.0'
  # s.osx.deployment_target = '10.7'
  s.requires_arc = true

  s.source_files = 'GokoUniversalLog/*'
  # s.resources = 'Assets'

  # s.ios.exclude_files = 'Classes/osx'
  # s.osx.exclude_files = 'Classes/ios'
  # s.public_header_files = 'Classes/**/*.h'
  s.frameworks = 'Foundation', 'UIKit'

end