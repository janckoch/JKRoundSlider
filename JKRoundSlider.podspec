Pod::Spec.new do |s|
  s.name     = 'JKRoundSlider'
  s.version  = '0.1'
  s.license  = 'MIT'
  s.summary  = "A round slider for iOS"
  s.homepage = 'https://github.com/janckoch/JKRoundSlider'
  s.authors  = { 'Jan Koch' => 'j.koch@neusta.de' }
  s.social_media_url = "https://twitter.com/_jankoch"
  s.platform = :ios
  s.source   = { :git => 'https://github.com/janckoch/JKRoundSlider.git', :tag => '0.1' }
  s.source_files = 'JKRoundSlider'
  s.requires_arc = true
  s.ios.deployment_target = '7.0'
end