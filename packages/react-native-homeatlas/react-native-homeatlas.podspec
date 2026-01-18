require 'json'

package = JSON.parse(File.read(File.join(__dir__, 'package.json')))

Pod::Spec.new do |s|
  s.name           = 'react-native-homeatlas'
  s.version        = package['version']
  s.summary        = package['description']
  s.description    = package['description']
  s.license        = package['license']
  s.author         = package['author']
  s.homepage       = package['homepage']
  s.platforms      = { :ios => '18.0' }
  s.source         = { :git => package['repository']['url'], :tag => "v#{s.version}" }
  s.source_files   = 'ios/**/*.{h,m,mm,swift}'
  s.swift_version  = '6.0'

  # Dependencies
  s.dependency 'ExpoModulesCore'
  
  # React Native dependency
  if defined?(install_modules_dependencies)
    install_modules_dependencies(s)
  else
    s.dependency 'React-Core'
  end
end
