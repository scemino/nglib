switch("path", "$projectDir/../src")

# This config.nims is used as an example and to test the examples, this definitions will not be
# applied to your application if you don't manually copy this file.

when defined(emscripten):
  # This path will only run if -d:emscripten is passed to nim.

  --cpu:wasm32 # Emscripten is 32bits.
  --cc:clang # Emscripten is very close to clang, so we ill replace it.
  when defined(windows):
    --clang.exe:emcc.bat  # Replace C
    --clang.linkerexe:emcc.bat # Replace C linker
    --clang.cpp.exe:emcc.bat # Replace C++
    --clang.cpp.linkerexe:emcc.bat # Replace C++ linker.
  else:
    --clang.exe:emcc  # Replace C
    --clang.linkerexe:emcc # Replace C linker
    --clang.cpp.exe:emcc # Replace C++
    --clang.cpp.linkerexe:emcc # Replace C++ linker.
  --listCmd # List what commands we are running so that we can debug them.

  --gc:arc # GC:arc is friendlier with crazy platforms.
  --exceptions:goto # Goto exceptions are friendlier with crazy platforms.

  --define:useMalloc
  --dynlibOverride:SDL2

  # Pass this to Emscripten linker to generate html file scaffold for us.
  switch("passC", "-Wno-warn-absolute-paths -Iemscripten -s USE_SDL=2")
  switch("passL", "-O3 -Lemscripten -s USE_SDL=2 -o out/index.html")
