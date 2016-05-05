Pod::Spec.new do |s|

  s.name         = "OHShareTool"
  s.version      = "0.1.0"
  s.summary      = "A share tool with UMengSocial."
  s.homepage     = "https://github.com/OceanHorn/OHShareTool"
  s.license  = { :type => 'MIT', :file => 'LICENSE' }
  s.author       = { "GuoYufu" => "OceanHorn@163.com" }
  s.requires_arc = true
  s.platform     = :ios
  s.platform     = :ios, '7.0'
  s.source       = { :git => "https://github.com/OceanHorn/OHShareTool.git", :tag => "0.1.0" }
  s.source_files = 'OHShareTool/*.{h,m}'
  s.public_header_files = "OHShareTool/*.h"
  s.framework  = 'UIKit'
  s.resources    = 'OHShareTool/OHShareTool.bundle'
  s.dependency 'UMengSocial', '~> 5.0'
  
end
