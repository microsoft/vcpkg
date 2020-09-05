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

# =============
# === Files ===
# =============

file(GLOB VCPKGLIB_SOURCES CONFIGURE_DEPENDS src/vcpkg/*.cpp)
file(GLOB VCPKGLIB_BASE_SOURCES CONFIGURE_DEPENDS src/vcpkg/base/*.cpp)
file(GLOB VCPKGLIB_INCLUDES CONFIGURE_DEPENDS include/vcpkg/*.h include/vcpkg/fwd/*.h)
file(GLOB VCPKGLIB_BASE_INCLUDES CONFIGURE_DEPENDS include/vcpkg/base/*.h include/vcpkg/base/fwd/*.h)

set(VCPKG_SOURCES ${CMAKE_CURRENT_SOURCE_DIR}/src/vcpkg.cpp)

set(VCPKGMETRICSUPLOADER_SOURCES ${CMAKE_CURRENT_SOURCE_DIR}/src/vcpkgmetricsuploader.cpp)

file(GLOB VCPKG_TEST_SOURCES CONFIGURE_DEPENDS src/vcpkg-test/*.cpp)
file(GLOB VCPKG_TEST_INCLUDES CONFIGURE_DEPENDS include/vcpkg-test/*.h)

file(GLOB VCPKG_FUZZ_SOURCES CONFIGURE_DEPENDS src/vcpkg-fuzz/*.cpp)

# ========================
# === System detection ===
# ========================

vcpkg_detect_compiler()
vcpkg_detect_standard_library()
vcpkg_detect_std_filesystem()

set(CMAKE_CXX_EXTENSIONS OFF)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_STANDARD 17)
if(MSVC)
    string(REGEX REPLACE "[-/]W[0-4]" "" CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS}")
endif()

# ===============
# === Targets ===
# ===============

# === Target: vcpkglib ===

add_library(vcpkglib
    ${VCPKGLIB_BASE_SOURCES}
    ${VCPKGLIB_SOURCES}
    ${VCPKGLIB_BASE_INCLUDES}
    ${VCPKGLIB_INCLUDES})
target_include_directories(vcpkglib PUBLIC include)

vcpkg_target_add_warning_options(vcpkglib)
target_compile_definitions(vcpkglib PUBLIC
    VCPKG_USE_STD_FILESYSTEM=$<BOOL:${VCPKG_USE_STD_FILESYSTEM}>)

set(THREADS_PREFER_PTHREAD_FLAG ON)
find_package(Threads REQUIRED)
target_link_libraries(vcpkglib PRIVATE Threads::Threads)

if(VCPKG_CXXFS_LIBRARY)
    target_link_libraries(vcpkglib PRIVATE ${VCPKG_CXXFS_LIBRARY})
endif()

if(MSVC)
    get_target_property(_srcs vcpkglib SOURCES)

    if(NOT CMAKE_GENERATOR MATCHES "Visual Studio .*")
        set_property(SOURCE src/pch.cpp APPEND PROPERTY OBJECT_OUTPUTS "${CMAKE_CURRENT_BINARY_DIR}/pch.pch")
        set_property(SOURCE ${_srcs} APPEND PROPERTY OBJECT_DEPENDS "${CMAKE_CURRENT_BINARY_DIR}/pch.pch")
    endif()

    set_source_files_properties(src/pch.cpp PROPERTIES COMPILE_FLAGS "/Ycpch.h")
    target_sources(vcpkglib PRIVATE src/pch.cpp)
    target_compile_options(vcpkglib PRIVATE /Yupch.h /FIpch.h /Zm200)
else()
    target_compile_options(vcpkglib PRIVATE -include "${CMAKE_CURRENT_SOURCE_DIR}/include/pch.h")
endif()

if (MINGW)
    target_compile_definitions(vcpkglib
        PUBLIC
            UNICODE
            _WIN32_WINNT=0x0601
            WINHTTP_ACCESS_TYPE_AUTOMATIC_PROXY=4
            __fastfail=exit)
    target_link_libraries(vcpkglib PUBLIC winhttp bcrypt version ole32 uuid)
endif()

# === Target: vcpkg ===

add_executable(vcpkg ${VCPKG_SOURCES})
target_link_libraries(vcpkg PRIVATE vcpkglib)
vcpkg_target_add_warning_options(vcpkg)

# === Target: vcpkgmetricsuploader ===

if(WIN32 AND NOT VCPKG_DISABLE_METRICS)
    add_executable(vcpkgmetricsuploader WIN32 ${VCPKGMETRICSUPLOADER_SOURCES})
    target_link_libraries(vcpkgmetricsuploader PRIVATE vcpkglib)
    vcpkg_target_add_warning_options(vcpkgmetricsuploader)
endif()

# === Target: vcpkg-test ===

if (BUILD_TESTING)
    enable_testing()

    add_executable(vcpkg-test
        ${VCPKG_TEST_SOURCES}
        ${VCPKG_TEST_INCLUDES})
    target_link_libraries(vcpkg-test PRIVATE vcpkglib)
    vcpkg_target_add_warning_options(vcpkg-test)

    add_test(NAME default COMMAND vcpkg-test --order rand --rng-seed time)

    if (VCPKG_BUILD_BENCHMARKING)
        target_compile_options(vcpkg-test PRIVATE -DCATCH_CONFIG_ENABLE_BENCHMARKING)
    endif()
endif()

# === Target: vcpkg-fuzz ===

if(VCPKG_BUILD_FUZZING)
    add_executable(vcpkg-fuzz ${VCPKG_FUZZ_SOURCES})
    target_link_libraries(vcpkg-fuzz PRIVATE vcpkglib)
    vcpkg_target_add_warning_options(vcpkg-fuzz)
endif()

# === Target: format ===

find_program(CLANG_FORMAT clang-format)
if(CLANG_FORMAT)
    # doing all of these formats in one line has a tendency to overflow the command line length
    add_custom_target(format
        COMMAND ${CLANG_FORMAT} -i -verbose ${CMAKE_CURRENT_SOURCE_DIR}/src/pch.cpp
        COMMAND ${CLANG_FORMAT} -i -verbose ${VCPKGLIB_BASE_SOURCES}
        COMMAND ${CLANG_FORMAT} -i -verbose ${VCPKGLIB_SOURCES}
        COMMAND ${CLANG_FORMAT} -i -verbose ${CMAKE_CURRENT_SOURCE_DIR}/include/pch.h
        COMMAND ${CLANG_FORMAT} -i -verbose ${VCPKGLIB_BASE_INCLUDES}
        COMMAND ${CLANG_FORMAT} -i -verbose ${VCPKGLIB_INCLUDES}

        COMMAND ${CLANG_FORMAT} -i -verbose ${VCPKG_SOURCES}
        COMMAND ${CLANG_FORMAT} -i -verbose ${VCPKGMETRICSUPLOADER_SOURCES}

        COMMAND ${CLANG_FORMAT} -i -verbose ${VCPKG_TEST_SOURCES}
        COMMAND ${CLANG_FORMAT} -i -verbose ${VCPKG_TEST_INCLUDES}

        COMMAND ${CLANG_FORMAT} -i -verbose ${VCPKG_FUZZ_SOURCES})
endif()
