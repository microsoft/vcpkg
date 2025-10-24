# Uses llvm-openmp from Vcpkg for Clang and AppleClang and the native OpenMP implementation for all other compilers.

set(_CMAKE_MODULE_PATH "${CMAKE_MODULE_PATH}")
if(CMAKE_CXX_COMPILER_ID MATCHES "^(Clang|AppleClang)$")
    list(PREPEND CMAKE_MODULE_PATH "${_VCPKG_INSTALLED_DIR}/${VCPKG_TARGET_TRIPLET}/share/llvm-openmp")
endif()
_find_package(${ARGS})
set(CMAKE_MODULE_PATH "${_CMAKE_MODULE_PATH}")
