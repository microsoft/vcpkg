cmake_minimum_required(VERSION 3.8)
project(breakpad CXX)

add_definitions(
    -DNOMINMAX
    -DUNICODE
    -DWIN32_LEAN_AND_MEAN
    -D_CRT_SECURE_NO_WARNINGS
    -D_CRT_SECURE_NO_DEPRECATE
    -D_CRT_NONSTDC_NO_DEPRECATE
)

set(CMAKE_DEBUG_POSTFIX d)
set(CMAKE_WINDOWS_EXPORT_ALL_SYMBOLS ON)

string(COMPARE EQUAL "${CMAKE_BUILD_TYPE}" "Release" DEFAULT_INSTALL_HEADERS)
option(INSTALL_HEADERS "Install header files" ${DEFAULT_INSTALL_HEADERS})

file(GLOB_RECURSE SOURCES src/processor/*.cc)
list(FILTER SOURCES EXCLUDE REGEX
    "_unittest|synth_minidump|/tests|/testdata|/linux|/mac|/android|/solaris|microdump_stackwalk|minidump_dump|minidump_stackwalk")

find_library(LIBDISASM_LIB NAMES libdisasmd libdisasm)

add_library(libbreakpad ${SOURCES})
target_link_libraries(libbreakpad PRIVATE ${LIBDISASM_LIB})

target_include_directories(libbreakpad
    PUBLIC
        $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/src>
        $<INSTALL_INTERFACE:include>
)

install(TARGETS libbreakpad EXPORT unofficial-breakpad-targets
    RUNTIME DESTINATION bin
    LIBRARY DESTINATION lib
    ARCHIVE DESTINATION lib
)

if(INSTALL_HEADERS)
    install(DIRECTORY src/google_breakpad DESTINATION include)
endif()

install(
    EXPORT unofficial-breakpad-targets
    FILE unofficial-breakpad-config.cmake
    NAMESPACE unofficial::breakpad::
    DESTINATION share/unofficial-breakpad
)
