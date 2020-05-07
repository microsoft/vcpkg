cmake_minimum_required(VERSION 3.14)

project(vcpkg CXX)
include(cmake/utilities.cmake)

# ===============
# === Options ===
# ===============

include(CMakeDependentOption)

option(BUILD_TESTING "Option for enabling testing" ON)
option(VCPKG_DISABLE_METRICS "Option for disabling metrics" OFF)
option(VCPKG_ALLOW_APPLE_CLANG "Option for allowing apple clang, even versions that we don't know will work" OFF)
option(VCPKG_DEVELOPMENT_WARNINGS "Option for turning on all warnings" ON)
option(VCPKG_WARNINGS_AS_ERRORS "Set warnings to be errors" ${VCPKG_DEVELOPMENT_WARNINGS})
option(VCPKG_BUILD_FUZZING "Option for enabling vcpkg-fuzz support" OFF)

CMAKE_DEPENDENT_OPTION(VCPKG_BUILD_BENCHMARKING "Option for enabling benchmarking" OFF
    "BUILD_TESTING" OFF)

if(WERROR)
    message(DEPRECATION "-DWERROR is no longer a supported flag. It doesn't do anything.")
endif()
if(DEFINE_DISABLE_METRICS)
    message(DEPRECATION "DEFINE_DISABLE_METRICS is now called VCPKG_DISABLE_METRICS.")
    set(VCPKG_DISABLE_METRICS ${DEFINE_DISABLE_METRICS} CACHE BOOL "Option for disabling metrics" FORCE)
endif()

vcpkg_detect_compiler()
vcpkg_detect_standard_library()
vcpkg_detect_std_filesystem()

# ======================
# === Compiler Flags ===
# ======================

set(CMAKE_CXX_EXTENSIONS OFF)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_STANDARD 17)

if(MSVC)
    # either MSVC, or clang-cl
    add_compile_options(-FC)

    if (MSVC_VERSION GREATER 1900)
        # Visual Studio 2017 or later
        add_compile_options(-permissive- -utf-8)
    endif()

    if(VCPKG_DEVELOPMENT_WARNINGS)
        string(REGEX REPLACE "[-/]W[0-4]" "" CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS}")

        add_compile_options(-W4)
        if(VCPKG_COMPILER STREQUAL "clang")
            add_compile_options(-Wmissing-prototypes -Wno-missing-field-initializers)
        endif()
    endif()

    if(VCPKG_WARNINGS_AS_ERRORS)
        add_compile_options(-WX)
    endif()
else()
    if(VCPKG_DEVELOPMENT_WARNINGS)
        add_compile_options(-Wall -Wextra -Wpedantic -Wno-unknown-pragmas -Wno-missing-field-initializers -Wno-redundant-move)

        # GCC and clang have different names for the same warning
        if(VCPKG_COMPILER STREQUAL "gcc")
            add_compile_options(-Wmissing-declarations)
        elseif(VCPKG_COMPILER STREQUAL "clang")
            add_compile_options(-Wmissing-prototypes)
        endif()
    endif()

    if(VCPKG_WARNINGS_AS_ERRORS)
        add_compile_options(-Werror)
    endif()
endif()

# ========================
# === System Libraries ===
# ========================

set(THREADS_PREFER_PTHREAD_FLAG ON)
find_package(Threads REQUIRED)
link_libraries(Threads::Threads)

add_compile_definitions(VCPKG_USE_STD_FILESYSTEM=$<BOOL:${VCPKG_USE_STD_FILESYSTEM}>)
if(VCPKG_REQUIRE_LINK_CXXFS)
    if(VCPKG_STANDARD_LIBRARY STREQUAL "libstdc++")
        link_libraries(stdc++fs)
    elseif(VCPKG_STANDARD_LIBRARY STREQUAL "libc++")
        link_libraries(c++fs)
    endif()
endif()

if (MINGW)
    add_compile_definitions(
        UNICODE
        _WIN32_WINNT=0x0601
        WINHTTP_ACCESS_TYPE_AUTOMATIC_PROXY=4
        __fastfail=exit)
    link_libraries(winhttp bcrypt version ole32 uuid)
endif()


# ===============
# === Targets ===
# ===============

add_compile_definitions(VCPKG_DISABLE_METRICS=$<BOOL:${VCPKG_DISABLE_METRICS}>)
include_directories(include)
file(GLOB_RECURSE VCPKGLIB_SOURCES CONFIGURE_DEPENDS src/vcpkg/*.cpp)
add_library(vcpkglib OBJECT ${VCPKGLIB_SOURCES})

add_executable(vcpkg src/vcpkg.cpp $<TARGET_OBJECTS:vcpkglib>)
if (WIN32)
    add_executable(vcpkgmetricsuploader WIN32 src/vcpkgmetricsuploader.cpp $<TARGET_OBJECTS:vcpkglib>)
endif()

if (BUILD_TESTING)
    file(GLOB_RECURSE VCPKGTEST_SOURCES CONFIGURE_DEPENDS src/vcpkg-test/*.cpp)

    enable_testing()
    add_executable(vcpkg-test ${VCPKGTEST_SOURCES} $<TARGET_OBJECTS:vcpkglib>)
    add_test(NAME default COMMAND vcpkg-test --order rand --rng-seed time)

    if (VCPKG_BUILD_BENCHMARKING)
        target_compile_options(vcpkg-test PRIVATE -DCATCH_CONFIG_ENABLE_BENCHMARKING)
    endif()
endif()

if(VCPKG_BUILD_FUZZING)
    file(GLOB_RECURSE VCPKGFUZZ_SOURCES src/vcpkg-fuzz/*.cpp)
    add_executable(vcpkg-fuzz ${VCPKGFUZZ_SOURCES} $<TARGET_OBJECTS:vcpkglib>)
endif()

find_program(CLANG_FORMAT clang-format)
if(CLANG_FORMAT)
    file(GLOB_RECURSE VCPKG_FORMAT_SOURCES CONFIGURE_DEPENDS src/*.cpp include/pch.h include/vcpkg/*.h include/vcpkg-test/*.h)
    add_custom_target(format COMMAND ${CLANG_FORMAT} -i -verbose ${VCPKG_FORMAT_SOURCES})
endif()

# ===========
# === PCH ===
# ===========

if(MSVC)
    get_target_property(_srcs vcpkglib SOURCES)

    if(NOT CMAKE_GENERATOR MATCHES "Visual Studio .*")
        set_property(SOURCE src/pch.cpp APPEND PROPERTY OBJECT_OUTPUTS "${CMAKE_CURRENT_BINARY_DIR}/pch.pch")
        set_property(SOURCE ${_srcs} APPEND PROPERTY OBJECT_DEPENDS "${CMAKE_CURRENT_BINARY_DIR}/pch.pch")
    endif()

    set_source_files_properties(src/pch.cpp PROPERTIES COMPILE_FLAGS "/Ycpch.h")
    target_sources(vcpkglib PRIVATE src/pch.cpp)
    target_compile_options(vcpkglib PRIVATE /Yupch.h /FIpch.h /Zm200)
endif()

