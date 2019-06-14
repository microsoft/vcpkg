cmake_minimum_required(VERSION 3.3)

project(vcpkg C CXX)

OPTION(DEFINE_DISABLE_METRICS "Option for disabling metrics" OFF)
OPTION(VCPKG_ALLOW_APPLE_CLANG "Option for allowing apple clang" OFF)

if(CMAKE_COMPILER_IS_GNUXX OR CMAKE_CXX_COMPILER_ID MATCHES "GNU")
    set(GCC 1)
elseif(CMAKE_CXX_COMPILER_ID MATCHES "AppleClang")
    if(NOT VCPKG_ALLOW_APPLE_CLANG)
        message(FATAL_ERROR
"Building the vcpkg tool requires support for the C++ Filesystem TS.
Apple clang versions 10.01 and below do not have support for it.
Please install gcc6 or newer from homebrew (brew install gcc6).
If you would like to try anyway, pass --allowAppleClang to bootstrap.sh.")
    else()
        set(CLANG 1)
    endif()
elseif(CMAKE_CXX_COMPILER_ID MATCHES "[Cc]lang")
    set(CLANG 1)
elseif(MSVC)
    add_compile_options(/std:c++17 /FC)
else()
    message(FATAL_ERROR "Unknown compiler: ${CMAKE_CXX_COMPILER_ID}")
endif()

if(GCC OR CLANG)
    add_compile_options(-std=c++1z)
    if(WERROR)
        add_compile_options(-Wall -Wno-unknown-pragmas -Werror)
    endif()
endif()

file(GLOB_RECURSE VCPKGLIB_SOURCES src/vcpkg/*.cpp)

if (DEFINE_DISABLE_METRICS)
    set(DISABLE_METRICS_VALUE "1")
else()
    set(DISABLE_METRICS_VALUE "0")
endif()

add_executable(vcpkg src/vcpkg.cpp ${VCPKGLIB_SOURCES})
target_compile_definitions(vcpkg PRIVATE -DDISABLE_METRICS=${DISABLE_METRICS_VALUE})
target_include_directories(vcpkg PRIVATE include)

if(CLANG)
    include(CheckCXXSourceCompiles)
    check_cxx_source_compiles("#include <iostream>
                               int main() { return __GLIBCXX__; }" USES_LIBSTDCXX)
    check_cxx_source_compiles("#include <iostream>
                               int main() { return _LIBCPP_VERSION; }" USES_LIBCXX)
    if ( NOT USES_LIBSTDCXX AND NOT USES_LIBCXX )
        message(FATAL_ERROR "Can't find which C++ runtime is in use")
    endif()
endif()

if(GCC OR (CLANG AND USES_LIBSTDCXX))
    target_link_libraries(vcpkg PRIVATE stdc++fs)
elseif(CLANG)
    target_link_libraries(vcpkg PRIVATE c++fs)
endif()

if(MSVC)
  get_target_property(_srcs vcpkg SOURCES)

  if(NOT CMAKE_GENERATOR MATCHES "Visual Studio .*")
    set_property(SOURCE src/pch.cpp APPEND PROPERTY OBJECT_OUTPUTS "${CMAKE_CURRENT_BINARY_DIR}/pch.pch")
    set_property(SOURCE ${_srcs} APPEND PROPERTY OBJECT_DEPENDS "${CMAKE_CURRENT_BINARY_DIR}/pch.pch")
  endif()

  set_source_files_properties(src/pch.cpp PROPERTIES COMPILE_FLAGS "/Ycpch.h")
  target_sources(vcpkg PRIVATE src/pch.cpp)
  target_compile_options(vcpkg PRIVATE /Yupch.h /FIpch.h /Zm200)
endif()

set(THREADS_PREFER_PTHREAD_FLAG ON)
find_package(Threads REQUIRED)
target_link_libraries(vcpkg PRIVATE Threads::Threads)
