Pod::Spec.new do |s|
  s.name             = 'dcf_primitives'
  s.version          = '0.0.1'
  s.summary          = 'Core UI primitives for the DCFlight framework'
  s.description      = <<-DESC
Core UI primitives implementing the DCFComponent protocol for the DCFlight framework.
This package provides View, Button, Text, Image, and ScrollView components.
                       DESC
  s.homepage         = 'https://github.com/squirelboy360/dcflight'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Your Company' => 'your-email@example.com' }
  s.source_files = 'Classes/**/*'
  s.public_header_files = 'Classes/**/*.h'
  s.dependency 'Flutter'
  s.dependency 'dcflight'  
  s.source           = { :path => '.' }
  
  s.platform = :ios, '13.5'
  s.swift_version = '5.0'
  
  # Flutter.framework does not contain a i386 slice.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
end