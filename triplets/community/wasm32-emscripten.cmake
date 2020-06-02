set(VCPKG_ENV_PASSTHROUGH EMSDK PATH)

if(NOT DEFINED ENV{EMSDK})
   message(FATAL_ERROR "The EMSDK environment variable must be defined")
endif()

if(NOT EXISTS $ENV{EMSDK}/upstream/emscripten/cmake/Modules/Platform/Emscripten.cmake)
   message(FATAL_ERROR "Emscripten.cmake toolchain file not found")
endif()

set(VCPKG_TARGET_ARCHITECTURE wasm32)
set(VCPKG_CRT_LINKAGE dynamic)
set(VCPKG_LIBRARY_LINKAGE static)
set(VCPKG_CMAKE_SYSTEM_NAME Emscripten)
set(VCPKG_CHAINLOAD_TOOLCHAIN_FILE $ENV{EMSDK}/upstream/emscripten/cmake/Modules/Platform/Emscripten.cmake)
