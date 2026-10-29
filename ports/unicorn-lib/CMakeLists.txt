cmake_minimum_required(VERSION 3.10)

project(Unicorn_Lib LANGUAGES CXX DESCRIPTION "Unicode library for C++ by Ross Smith")
set(CMAKE_CXX_STANDARD 17)
option(UNICORN_LIB_SKIP_HEADERS "If the headers installation is skipped or not." OFF)

find_package(ZLIB REQUIRED)
find_package(PkgConfig REQUIRED)
pkg_check_modules(PCRE2 IMPORTED_TARGET REQUIRED libpcre2-8)

file(GLOB_RECURSE UNICORN_LIB_SOURCES "${PROJECT_SOURCE_DIR}/unicorn/*.cpp")
list(FILTER UNICORN_LIB_SOURCES EXCLUDE REGEX "(.*)-test.cpp(.*)")

add_library(unicorn-lib ${UNICORN_LIB_SOURCES})
target_include_directories(unicorn-lib PUBLIC "${PROJECT_SOURCE_DIR}")
target_link_libraries(unicorn-lib PRIVATE PkgConfig::PCRE2 ZLIB::ZLIB)
if(WIN32)
    target_compile_definitions(unicorn-lib PRIVATE -DNOMINMAX -DUNICODE -D_UNICODE -D_CRT_SECURE_NO_WARNINGS)
else()
    find_package(Iconv REQUIRED)
    target_link_libraries(unicorn-lib PRIVATE Iconv::Iconv)
    target_compile_definitions(unicorn-lib PRIVATE -D_XOPEN_SOURCE=700)
endif()

if(NOT UNICORN_LIB_SKIP_HEADERS)
    install(DIRECTORY ${PROJECT_SOURCE_DIR}/unicorn DESTINATION include FILES_MATCHING PATTERN "*.hpp")
endif()
install(TARGETS unicorn-lib
        RUNTIME DESTINATION bin
        LIBRARY DESTINATION lib
        ARCHIVE DESTINATION lib
       )