
Pod::Spec.new do |s|
  s.name             = 'Preview'
  s.version          = '0.1.0'
  s.summary          = 'A short description of qcs.r.ios.workbench.'
  s.description      = <<-DESC
                debug
                       DESC

  s.homepage         = 'https://github.com/seeuli/preview'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'seeuli' => 'l1649675100@163.com' }
  s.source           = { :git => 'git@github.com:seeuli/preview.git', :tag => s.version.to_s }
  s.ios.deployment_target = '9.0'
  s.frameworks = 'UIKit', 'AVFoundation'

  s.source_files = 'Preview/**/*.swift'
  s.resources = 'Preview/**/*.xcassets'

  s.dependency 'SnapKit'
end
