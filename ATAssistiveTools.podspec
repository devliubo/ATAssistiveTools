Pod::Spec.new do |s|

  s.name     = 'ATAssistiveTools'
  s.version  = '0.1.0'
  s.author   =  { 'devliubo' => 'vipliubo@vip.qq.com' }
  s.license  = { :type => 'MIT', :file => 'LICENSE' }
  s.homepage = 'https://github.com/devliubo/ATAssistiveTools'
  s.summary  = 'ATAssistiveTools'

  s.source   = { :git => 'https://github.com/devliubo/ATAssistiveTools.git' }
  s.ios.deployment_target = '8.0'
  s.requires_arc = true

  s.default_subspec = 'Core'

  s.subspec 'Core' do |cs|
    cs.source_files = 'ATAssistiveTools/**/*.{h,m}'
    cs.public_header_files = "ATAssistiveTools/**/*.h"
    cs.requires_arc = true
  end

  s.subspec 'CustomizeViews' do |cs|
    cs.dependency 'ATAssistiveTools/Core'
    cs.dependency 'GCDWebServer/WebUploader'
    cs.source_files = 'ATCustomizeViews/**/*.{h,m}'
    cs.public_header_files = "ATCustomizeViews/**/*.h"
    cs.requires_arc = true
  end

end
