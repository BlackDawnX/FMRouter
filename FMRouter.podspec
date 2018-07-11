Pod::Spec.new do |s|
  s.name = 'FMRouter'
  s.version = '1.0.0'
  s.license = 'MIT'
  s.summary = 'A simple router framework in Swift.'
  s.homepage = 'https://github.com/BlackDawnX/FMRouter'
  s.authors = { 'Fitmao' => 'ffitmao@gmail.com' }
  s.swift-version = '4.0'
  s.source = { :git => 'https://github.com/BlackDawnX/FMRouter.git', :tag => s.version }
  s.source_files = 'FMRouter/*.swift'  
  s.frameworks = 'UIKit'
end
