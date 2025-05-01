Pod::Spec.new do |s|
  s.name             = 'dcflight'
  s.version          = '0.0.1'
  s.summary          = 'Build native apps in dart'
  s.description      = <<-DESC
A crossplatform framework.
                       DESC
  s.homepage         = 'https://github.com/squirelboy360/dcflight'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Tahiru' => 'squirelwares@gmail.com' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.platform = :ios, '13.5'
  s.dependency 'Flutter'
  s.source = {
    :git => 'https://github.com/DotCorr/yoga.git',
    :branch => 'main'
  }
  s.swift_version = '5.0'

 # Flutter.framework does not contain a i386 slice.
 s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
end