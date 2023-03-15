Pod::Spec.new do |s|
  s.name     = 'DDMinizip'
  s.version  = '1.0.0'
  s.license  = 'libz'
  s.summary  = "Based on code from acsolu@gmail.com, expanded and modified to work as a 'drop-in' static library for macOS and iOS"
  s.description = "Based on code from acsolu@gmail.com, expanded and modified to work as a 'drop-in' static library for macOS and iOS"

  s.homepage = 'https://github.com/PaulPaulBoBo/Minizip'
  s.author = 'PaulPaulBoBo'

  s.source   = { :git => 'git@github.com:PaulPaulBoBo/Minizip.git' }
  s.source_files = 'src/*.{m,h}'
end
