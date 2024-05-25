require "mkmf"

if Gem::Platform.local.os === "darwin"
  $CXXFLAGS += " -stdlib=libc++ -std=c++17"
end
$CXXFLAGS += " #{`pkg-config --cflags --libs opencv4`}"
$LDFLAGS += " #{`pkg-config --cflags --libs opencv4`}"

create_makefile("ext")
