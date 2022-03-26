cmake_minimum_required(VERSION 3.10)

project(Unicorn_Lib LANGUAGES CXX DESCRIPTION "Unicode library for C++ by Ross Smith")
set(CMAKE_CXX_STANDARD 17)
option(UNICORN_LIB_SKIP_HEADERS "If the headers installation is skipped or not." OFF)

include(SelectLibraryConfigurations)
find_package(ZLIB REQUIRED)
find_library(PCRE2_LIBRARY_DEBUG NAMES pcre2-8d pcre2-8-staticd HINTS ${INSTALLED_LIB_PATH})
find_library(PCRE2_LIBRARY_RELEASE NAMES pcre2-8 pcre2-8-static HINTS ${INSTALLED_LIB_PATH})
select_library_configurations(PCRE2)

file(GLOB_RECURSE UNICORN_LIB_SOURCES ${PROJECT_SOURCE_DIR}/unicorn/*.cpp)
foreach(ITR ${UNICORN_LIB_SOURCES})
    if(ITR MATCHES "(.*)-test.cpp(.*)")
        list(REMOVE_ITEM UNICORN_LIB_SOURCES ${ITR})
    endif()
endforeach()
add_library(unicorn-lib ${UNICORN_LIB_SOURCES})
target_include_directories(
    unicorn-lib
    PUBLIC ${PROJECT_SOURCE_DIR}
)
target_compile_definitions(
    unicorn-lib
    PRIVATE -DUNICODE -D_UNICODE _CRT_SECURE_NO_WARNINGS
)

target_link_libraries(unicorn-lib PUBLIC ${PCRE2_LIBRARY})
target_link_libraries(unicorn-lib PUBLIC ZLIB::ZLIB)

if(NOT UNICORN_LIB_SKIP_HEADERS)
    install(DIRECTORY ${PROJECT_SOURCE_DIR}/unicorn DESTINATION include FILES_MATCHING PATTERN "*.hpp")
endif()
install(TARGETS unicorn-lib
        RUNTIME DESTINATION bin
        LIBRARY DESTINATION lib
        ARCHIVE DESTINATION lib
       )