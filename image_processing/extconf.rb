require 'mkmf'

$CXXFLAGS += " -std=c++17 #{`pkg-config --cflags --libs opencv4`}"
# $LDFLAGS += " -ltesseract "
$LDFLAGS += " #{`pkg-config --cflags --libs opencv4`}"

create_makefile('ext')
