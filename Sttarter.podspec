Pod::Spec.new do |s|
  s.name             = 'Sttarter'
  s.version          = '0.1.6'
  s.summary          = 'By far the most Sttarter I have seen in my entire life. No joke.'
 
  s.description      = <<-DESC
This Sttarter changes its dependancy gradually makes your app look fantastic!
                       DESC
 
  s.homepage         = 'https://github.com/jaico/Sttarter.git'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { '<Jaico>' => '<jaicovarghese@gmail.com>' }
  s.source           = { :git => 'https://github.com/jaico/Sttarter.git', :tag => s.version.to_s }
 
  s.ios.deployment_target = '8.0'
  s.swift_version = '3.0'
  s.source_files = 'Sttarter/*.{framework,h}'
 
end