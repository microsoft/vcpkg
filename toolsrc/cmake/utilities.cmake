# Outputs to Cache: VCPKG_COMPILER
function(vcpkg_detect_compiler)
    if(NOT DEFINED CACHE{VCPKG_COMPILER})
        if(CMAKE_COMPILER_IS_GNUXX OR CMAKE_CXX_COMPILER_ID MATCHES "GNU")
            if(CMAKE_CXX_COMPILER_VERSION VERSION_LESS 6.0)
                message(FATAL_ERROR [[
The g++ version picked up is too old; please install a newer compiler such as g++-7.
On Ubuntu try the following:
    sudo add-apt-repository ppa:ubuntu-toolchain-r/test -y
    sudo apt-get update -y
    sudo apt-get install g++-7 -y
On CentOS try the following:
    sudo yum install centos-release-scl
    sudo yum install devtoolset-7
    scl enable devtoolset-7 bash
]])
            endif()

            set(COMPILER "gcc")
        elseif(CMAKE_CXX_COMPILER_ID MATCHES "AppleClang")
            #[[
            Note: CMAKE_SYSTEM_VERSION uses darwin versions
                - Darwin 19.0.0 = macOS 10.15, iOS 13
                - Darwin 18.0.0 = macOS 10.14, iOS 12
                - Darwin 17.0.0 = macOS 10.13, iOS 11
                - Darwin 16.0.0 = macOS 10.12, iOS 10
            ]]
            if(CMAKE_SYSTEM_VERSION VERSION_LESS "19.0.0" AND NOT VCPKG_ALLOW_APPLE_CLANG)
                message(FATAL_ERROR [[
Building the vcpkg tool requires support for the C++ Filesystem TS.
macOS versions below 10.15 do not have support for it with Apple Clang.
Please install gcc6 or newer from homebrew (brew install gcc).
If you would like to try anyway, pass --allowAppleClang to bootstrap.sh.
]])
            endif()
            set(COMPILER "clang")
        elseif(CMAKE_CXX_COMPILER_ID MATCHES "[Cc]lang")
            set(COMPILER "clang")
        elseif(MSVC)
            set(COMPILER "msvc")
        else()
            message(FATAL_ERROR "Unknown compiler: ${CMAKE_CXX_COMPILER_ID}")
        endif()

        set(VCPKG_COMPILER ${COMPILER}
            CACHE STRING
            "The compiler in use; one of gcc, clang, msvc")
    endif()
endfunction()

# Outputs to Cache: VCPKG_STANDARD_LIBRARY
function(vcpkg_detect_standard_library)
    if(NOT DEFINED CACHE{VCPKG_STANDARD_LIBRARY})
        include(CheckCXXSourceCompiles)

        message(STATUS "Detecting the C++ standard library")

        # note: since <ciso646> is the smallest header, generally it's used to get the standard library version
        set(CMAKE_REQUIRED_QUIET ON)
        check_cxx_source_compiles([[
#include <ciso646>
#if !defined(__GLIBCXX__)
#error "not libstdc++"
#endif
int main() {}
]]
            _VCPKG_STANDARD_LIBRARY_LIBSTDCXX)
        check_cxx_source_compiles([[
#include <ciso646>
#if !defined(_LIBCPP_VERSION)
#error "not libc++"
#endif
int main() {}
]]
            _VCPKG_STANDARD_LIBRARY_LIBCXX)
        check_cxx_source_compiles([[
#include <ciso646>
#if !defined(_MSVC_STL_VERSION)
#error "not MSVC stl"
#endif
int main() {}
]]
            _VCPKG_STANDARD_LIBRARY_MSVC_STL)
        if(_VCPKG_STANDARD_LIBRARY_LIBSTDCXX)
            set(STANDARD_LIBRARY "libstdc++")
        elseif(_VCPKG_STANDARD_LIBRARY_LIBCXX)
            set(STANDARD_LIBRARY "libc++")
        elseif(_VCPKG_STANDARD_LIBRARY_MSVC_STL)
            set(STANDARD_LIBRARY "msvc-stl")
        else()
            message(FATAL_ERROR "Can't find which C++ runtime is in use")
        endif()

        set(VCPKG_STANDARD_LIBRARY ${STANDARD_LIBRARY}
            CACHE STRING
            "The C++ standard library in use; one of libstdc++, libc++, msvc-stl")

        message(STATUS "Detecting the C++ standard library - ${VCPKG_STANDARD_LIBRARY}")
    endif()
endfunction()

# Outputs to Cache: VCPKG_USE_STD_FILESYSTEM, VCPKG_REQUIRE_LINK_CXXFS
function(vcpkg_detect_std_filesystem)
    vcpkg_detect_standard_library()

    if(NOT DEFINED CACHE{VCPKG_USE_STD_FILESYSTEM})
        include(CheckCXXSourceCompiles)

        message(STATUS "Detecting how to use the C++ filesystem library")

        set(CMAKE_REQUIRED_QUIET ON)
        if(VCPKG_STANDARD_LIBRARY STREQUAL "libstdc++")
            check_cxx_source_compiles([[
#include <ciso646>
#if defined(_GLIBCXX_RELEASE) && _GLIBCXX_RELEASE >= 9
#error "libstdc++ after version 9 does not require -lstdc++fs"
#endif
int main() {}
]]
                _VCPKG_REQUIRE_LINK_CXXFS)

            check_cxx_source_compiles([[
#include <ciso646>
#if !defined(_GLIBCXX_RELEASE) || _GLIBCXX_RELEASE < 8
#error "libstdc++ before version 8 does not support <filesystem>"
#endif
int main() {}
]]
                _VCPKG_USE_STD_FILESYSTEM)
        elseif(VCPKG_STANDARD_LIBRARY STREQUAL "libc++")
            if(CMAKE_CXX_COMPILER_ID MATCHES "AppleClang")
                # AppleClang never requires (or allows) -lc++fs, even with libc++ version 8.0.0
                set(_VCPKG_REQUIRE_LINK_CXXFS OFF)
            else()
                check_cxx_source_compiles([[
#include <ciso646>
#if _LIBCPP_VERSION >= 9000
#error "libc++ after version 9 does not require -lc++fs"
#endif
int main() {}
]]
                    _VCPKG_REQUIRE_LINK_CXXFS)
            endif()

            # We don't support versions of libc++ < 7.0.0, and libc++ 7.0.0 has <filesystem>
            set(_VCPKG_USE_STD_FILESYSTEM ON)
        elseif(VCPKG_STANDARD_LIBRARY STREQUAL "msvc-stl")
            check_cxx_source_compiles(
                "#include <ciso646>
                #if !defined(_MSVC_STL_UPDATE) || _MSVC_STL_UPDATE < 201803
                #error \"MSVC STL before 15.7 does not support <filesystem>\"
                #endif
                int main() {}"
                _VCPKG_USE_STD_FILESYSTEM)

            set(_VCPKG_REQUIRE_LINK_CXXFS OFF)
        endif()

        set(VCPKG_USE_STD_FILESYSTEM ${_VCPKG_USE_STD_FILESYSTEM}
            CACHE BOOL
            "Whether to use <filesystem>, as opposed to <experimental/filesystem>"
            FORCE)
        set(VCPKG_REQUIRE_LINK_CXXFS ${_VCPKG_REQUIRE_LINK_CXXFS}
            CACHE BOOL
            "Whether it's required to pass -l[std]c++fs in order to use <filesystem>"
            FORCE)

        if(VCPKG_USE_STD_FILESYSTEM)
            set(msg "<filesystem>")
        else()
            set(msg "<experimental/filesystem>")
        endif()
        if(VCPKG_REQUIRE_LINK_CXXFS)
            set(msg "${msg} with -l[std]c++fs")
        endif()

        message(STATUS "Detecting how to use the C++ filesystem library - ${msg}")
    endif()
endfunction()
