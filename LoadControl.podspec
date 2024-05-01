Pod::Spec.new do |s|
  s.name                  = 'LoadControl'
  s.version               = '1.0.0'
  s.summary               = 'A standard control that can initiate the loading of a scroll view’s contents.'
  
  s.author                = { 'verny-tran' => 'verny-tran@icloud.com' }
  s.social_media_url      = 'https://github.com/verny-tran'

  s.homepage              = 'https://github.com/verny-tran/LoadControl'
  s.screenshots           = 'github.com/verny-tran/LoadControl/blob/main/Resources/Images/Refresh.gif', 'github.com/verny-tran/LoadControl/blob/main/Resources/Images/Load.gif'
  
  s.license               = { :type => 'MIT', :file => 'LICENSE' }
  s.readme                = 'https://github.com/verny-tran/LoadControl/blob/main/README.md'
    
  s.source                = { :git => 'https://github.com/verny-tran/LoadControl.git', :tag => 'v1.0.0' }
  s.source_files          = 'Sources/**/*'
  
  s.swift_versions        = ['5.0']
  
  s.ios.deployment_target = '13.0'
  s.ios.framework         = 'UIKit'
  
  # s.resource_bundles = {
  #   '${POD_NAME}' => ['${POD_NAME}/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
end
