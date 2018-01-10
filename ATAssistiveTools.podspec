Pod::Spec.new do |s|

  s.name     = 'ATAssistiveTools'
  s.version  = '0.1.0'
  s.author   =  { 'devliubo' => 'vipliubo@vip.qq.com' }
  s.license  = { :type => 'MIT', :file => 'LICENSE' }
  s.homepage = 'https://github.com/devliubo/ATAssistiveTools'
  s.summary  = 'ATAssistiveTools'

  s.source   = { :git => 'https://github.com/devliubo/ATAssistiveTools.git',
                 :tag => "v#{s.version}" }
  s.ios.deployment_target = '8.0'
  s.requires_arc = true
  s.user_target_xcconfig = { 'CLANG_ALLOW_NON_MODULAR_INCLUDES_IN_FRAMEWORK_MODULES' => 'YES' }

  s.default_subspec = 'Core'

  s.subspec 'Core' do |cs|
    cs.ios.source_files = 'ATAssistiveTools/**/*.{h,m}'
    cs.ios.public_header_files = 'ATAssistiveTools/**/*.h'
    cs.requires_arc = true
  end

  s.subspec 'CustomizeViews' do |cs|
    cs.dependency 'ATAssistiveTools/Core'
    cs.dependency 'GCDWebServer/WebUploader'
    cs.ios.source_files = 'ATCustomizeViews/**/*.{h,m}'
    cs.ios.public_header_files = 'ATCustomizeViews/**/*.h'
    cs.requires_arc = true
  end

end
