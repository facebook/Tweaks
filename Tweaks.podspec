Pod::Spec.new do |spec|
  spec.name         = 'Tweaks'
  spec.version      = '2.0.0'
  spec.license      =  { :type => 'BSD' }
  spec.homepage     = 'https://github.com/facebook/Tweaks'
  spec.authors      = { 'Grant Paul' => 'tweaks@grantpaul.com', 'Kimon Tsinteris' => 'kimon@mac.com' }
  spec.summary      = 'Easily adjust parameters for iOS apps in development.'
  spec.source       = { :git => 'https://github.com/facebook/Tweaks.git', :tag => '2.0.0' }
  spec.ios.source_files = 'FBTweak/Model/*.{h,m}', 'FBTweak/Inline/*.{h,m}', 'FBTweak/UI/*.{h,m}', 
  spec.mac.source_files = 'FBTweak/Model/*.{h,m}', 'FBTweak/Inline/*.{h,m}', 'FBTweak/Mac/*.{h,m}',
  spec.requires_arc = true
  spec.social_media_url = 'https://twitter.com/fbOpenSource'
  spec.ios.framework = 'MessageUI'
  
  spec.ios.deployment_target = '6.0'
  spec.osx.deployment_target = '10.10'
end
