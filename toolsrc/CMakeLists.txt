cmake_minimum_required(VERSION 3.14)

project(vcpkg C CXX)

OPTION(DEFINE_DISABLE_METRICS "Option for disabling metrics" OFF)
OPTION(VCPKG_ALLOW_APPLE_CLANG "Option for allowing apple clang" OFF)
OPTION(VCPKG_DEVELOPMENT_WARNINGS "Option for turning on all warnings, and making them errors" ON)
OPTION(BUILD_TESTING "Option for enabling testing" ON)
OPTION(VCPKG_BUILD_BENCHMARKING "Option for enabling benchmarking" OFF)

# for backwards compatibility with existing code
if (WERROR)
    set(VCPKG_DEVELOPMENT_WARNINGS On)
endif()


if (DEFINE_DISABLE_METRICS)
    set(DISABLE_METRICS_VALUE "1")
else()
    set(DISABLE_METRICS_VALUE "0")
endif()

if(CMAKE_COMPILER_IS_GNUXX OR CMAKE_CXX_COMPILER_ID MATCHES "GNU")
    set(GCC 1)
elseif(CMAKE_CXX_COMPILER_ID MATCHES "AppleClang")
    if(CMAKE_CXX_COMPILER_VERSION VERSION_GREATER_EQUAL "11.0.0")
        set(CLANG 1)
        # Disable linking with libc++fs because this features are added in libc++ library
        set(NO_LIBCXXFS 1)
    elseif(NOT VCPKG_ALLOW_APPLE_CLANG)
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
    if(CMAKE_CXX_COMPILER_VERSION VERSION_GREATER_EQUAL "9.0.0")
        set(NO_LIBCXXFS 1)
        add_compile_definitions(_LIBCPP_NO_EXPERIMENTAL_DEPRECATION_WARNING_FILESYSTEM=1)
    endif()
elseif(NOT MSVC)
    message(FATAL_ERROR "Unknown compiler: ${CMAKE_CXX_COMPILER_ID}")
endif()

set(THREADS_PREFER_PTHREAD_FLAG ON)
find_package(Threads REQUIRED)

add_definitions(-DDISABLE_METRICS=${DISABLE_METRICS_VALUE})
include_directories(include)
link_libraries(Threads::Threads)

if(CLANG AND NOT MSVC)
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
    link_libraries(stdc++fs)
elseif(CLANG AND NOT MSVC AND NOT NO_LIBCXXFS)
    link_libraries(c++fs)
endif()

if(MSVC)
    # either MSVC, or clang-cl
    add_compile_options(-FC)

    if (MSVC_VERSION GREATER 1900)
        # Visual Studio 2017 or later
        add_compile_options(-std:c++17 -permissive-)
    else()
        # Visual Studio 2015
        add_compile_options(-std:c++latest)
    endif()

    if(VCPKG_DEVELOPMENT_WARNINGS)
        string(REGEX REPLACE "/W[0-4]" "" CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS}")
        add_compile_options(-W4 -WX)

        if (CLANG)
            add_compile_options(-Wmissing-prototypes -Wno-missing-field-initializers)
        endif()
    endif()
elseif(GCC OR CLANG)
    add_compile_options(-std=c++1z)

    if(VCPKG_DEVELOPMENT_WARNINGS)
        add_compile_options(-Wall -Wextra -Wpedantic -Wno-unknown-pragmas -Wno-missing-field-initializers -Werror)

        # GCC and clang have different names for the same warning
        if (GCC)
            add_compile_options(-Wmissing-declarations)
        elseif(CLANG)
            add_compile_options(-Wmissing-prototypes)
        endif()
    endif()
endif()

file(GLOB_RECURSE VCPKGLIB_SOURCES CONFIGURE_DEPENDS src/vcpkg/*.cpp)

add_library(vcpkglib OBJECT ${VCPKGLIB_SOURCES})
add_executable(vcpkg src/vcpkg.cpp $<TARGET_OBJECTS:vcpkglib>)

if (BUILD_TESTING)
    file(GLOB_RECURSE VCPKGTEST_SOURCES CONFIGURE_DEPENDS src/vcpkg-test/*.cpp)

    enable_testing()
    add_executable(vcpkg-test
        ${VCPKGTEST_SOURCES}
        $<TARGET_OBJECTS:vcpkglib>)

    add_test(NAME default COMMAND vcpkg-test)

    if (VCPKG_BUILD_BENCHMARKING)
        target_compile_options(vcpkg-test PRIVATE -DCATCH_CONFIG_ENABLE_BENCHMARKING)
    endif()

    find_program(CLANG_FORMAT clang-format)
    if (CLANG_FORMAT)
        file(GLOB_RECURSE VCPKG_FORMAT_SOURCES CONFIGURE_DEPENDS src/*.cpp include/pch.h include/vcpkg/*.h include/vcpkg-test/*.h)
        add_custom_target(format COMMAND ${CLANG_FORMAT} -i -verbose ${VCPKG_FORMAT_SOURCES})
    endif()
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
