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
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.public_header_files = 'Classes/**/*.h'
  s.dependency 'Flutter'
  s.dependency 'dcflight'
  s.dependency 'yoga'
  
  s.platform = :ios, '13.0'
  s.swift_version = '5.0'
  
  # This line ensures that the pod is linked properly
  s.xcconfig = { 'DEFINES_MODULE' => 'YES' }
end