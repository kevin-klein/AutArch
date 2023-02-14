require 'mkmf'

if Gem::Platform.local.os === 'darwin'
$CXXFLAGS += ' -stdlib=libc++ -std=c++17'
else  
  $CXXFLAGS += " #{`pkg-config --cflags --libs opencv4`}"
  $LDFLAGS += " #{`pkg-config --cflags --libs opencv4`}"
end

create_makefile('ext')
