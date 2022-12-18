require 'mkmf'


$CXXFLAGS += " -stdlib=libc++ -std=c++17"
$CXXFLAGS += " #{`pkg-config --cflags --libs opencv4`}"

# $LDFLAGS += " -ltesseract "
$LDFLAGS += " #{`pkg-config --cflags --libs opencv4`}"

create_makefile('ext')
