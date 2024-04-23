Pod::Spec.new do |s|
  s.name             = 'LoadControl'
  s.version          = '0.1.2'
  s.summary          = 'A standard control that can initiate the loading of a scroll view’s contents.'

  # s.description      = <<-DESC
  # TODO: Add long description of the pod here.
  # DESC

  s.homepage         = 'https://github.com/verny-tran/LoadControl'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'verny-tran' => 'verny-tran@icloud.com' }
  s.social_media_url = 'https://github.com/verny-tran'

  s.swift_versions = ['5.0']
  
  s.ios.deployment_target = '13.0'
    
  s.source           = { :git => 'https://github.com/verny-tran/LoadControl.git', :tag => 'v0.1.2' }
  s.source_files = 'Sources/*'
  
  # s.resource_bundles = {
  #   '${POD_NAME}' => ['${POD_NAME}/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
end
