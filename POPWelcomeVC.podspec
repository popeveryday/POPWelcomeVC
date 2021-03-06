Pod::Spec.new do |s|
s.name             = "POPWelcomeVC"
s.version          = "0.2.2"
s.summary          = "Welcome view for displaying logo, loading resources, and show passcode request form for Object-c project."
s.homepage         = "https://github.com/popeveryday/POPWelcomeVC"
s.license          = 'MIT'
s.author           = { "popeveryday" => "popeveryday@gmail.com" }
s.source           = { :git => "https://github.com/popeveryday/POPWelcomeVC.git", :tag => s.version.to_s }
s.platform     = :ios, '8.0'
s.requires_arc = true
s.source_files = 'Pod/Classes/**/*.{h,m,c}'
s.dependency 'POPLib', '~> 0.1'
end
