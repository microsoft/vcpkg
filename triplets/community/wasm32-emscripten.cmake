set(VCPKG_ENV_PASSTHROUGH_UNTRACKED EMSDK PATH)

find_path(EMSCRIPTEN_ROOT "emcc")
if(NOT EMSCRIPTEN_ROOT)
    # Old-lookup method, try to infer emscripten directory based on $EMSDK environment variable
    if(NOT DEFINED ENV{EMSDK})
        message(FATAL_ERROR "emcc compiler not found in PATH")
    endif()
    set(EMSCRIPTEN_ROOT "ENV{EMSDK}//upstream/emscripten")
endif()

if(NOT EXISTS ${EMSCRIPTEN_ROOT}/cmake/Modules/Platform/Emscripten.cmake)
    message(FATAL_ERROR "Emscripten.cmake toolchain file not found")
endif()

set(VCPKG_TARGET_ARCHITECTURE wasm32)
set(VCPKG_CRT_LINKAGE dynamic)
set(VCPKG_LIBRARY_LINKAGE static)
set(VCPKG_CMAKE_SYSTEM_NAME Emscripten)
set(VCPKG_CHAINLOAD_TOOLCHAIN_FILE ${EMSCRIPTEN_ROOT}/cmake/Modules/Platform/Emscripten.cmake)
