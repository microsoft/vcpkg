cmake_minimum_required(VERSION 3.8)
project(breakpad CXX)

set(CMAKE_CXX_STANDARD 11)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

add_definitions(
    -DNOMINMAX
    -DUNICODE
    -DWIN32_LEAN_AND_MEAN
    -D_CRT_SECURE_NO_WARNINGS
    -D_CRT_SECURE_NO_DEPRECATE
    -D_CRT_NONSTDC_NO_DEPRECATE
    -D_LIBCPP_VERSION
)

set(CMAKE_DEBUG_POSTFIX d)

string(COMPARE EQUAL "${CMAKE_BUILD_TYPE}" "Release" DEFAULT_INSTALL_HEADERS)
option(INSTALL_HEADERS "Install header files" ${DEFAULT_INSTALL_HEADERS})

# libbreakpad target
file(GLOB_RECURSE LIBBREAKPAD_SOURCES src/processor/*.cc)
list(FILTER LIBBREAKPAD_SOURCES EXCLUDE REGEX
    "_unittest|synth_minidump|/tests|/testdata|/linux|/mac|/android|/solaris|microdump_stackwalk|minidump_dump|minidump_stackwalk")

find_library(LIBDISASM_LIB NAMES libdisasmd libdisasm)

add_library(libbreakpad ${LIBBREAKPAD_SOURCES})
target_link_libraries(libbreakpad PRIVATE ${LIBDISASM_LIB})

target_include_directories(libbreakpad
    PUBLIC
        $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/src>
        $<INSTALL_INTERFACE:include>
)

set(TARGETS libbreakpad)
if(WIN32)
    # libbreakpad_client target does not currently work on non-windows
    if(WIN32)
        file(GLOB_RECURSE LIBBREAKPAD_CLIENT_SOURCES src/client/windows/*.cc src/common/windows/*.cc)
        include_directories("$ENV{VSINSTALLDIR}/DIA SDK/include")
    elseif(APPLE)
        add_definitions(-DHAVE_MACH_O_NLIST_H)
        file(GLOB_RECURSE LIBBREAKPAD_CLIENT_SOURCES src/client/mac/*.cc src/common/mac/*.cc)
    else()
        add_definitions(-DHAVE_A_OUT_H)
        file(GLOB_RECURSE LIBBREAKPAD_CLIENT_SOURCES src/client/linux/*.cc src/common/linux/*.cc)
    endif()
    file(GLOB LIBBREAKPAD_COMMON_SOURCES src/common/*.cc src/common/*.c src/client/*.cc)
    list(APPEND LIBBREAKPAD_CLIENT_SOURCES ${LIBBREAKPAD_COMMON_SOURCES})
    list(FILTER LIBBREAKPAD_CLIENT_SOURCES EXCLUDE REGEX "/tests|/unittests|_unittest")
    if(WIN32)
        list(FILTER LIBBREAKPAD_CLIENT_SOURCES EXCLUDE REGEX "language.cc|path_helper.cc|stabs_to_module.cc|stabs_reader.cc|minidump_file_writer.cc")
    endif()

    add_library(libbreakpad_client ${LIBBREAKPAD_CLIENT_SOURCES})
    target_link_libraries(libbreakpad_client PRIVATE wininet.lib)

    target_include_directories(libbreakpad_client
        PUBLIC
            $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/src>
            $<INSTALL_INTERFACE:include>
    )
    list(APPEND TARGETS libbreakpad_client)
endif()

# installation
install(TARGETS ${TARGETS} EXPORT unofficial-breakpad-targets
    RUNTIME DESTINATION bin
    LIBRARY DESTINATION lib
    ARCHIVE DESTINATION lib
)

if(INSTALL_HEADERS)
    if(WIN32)
        set(HEADER_EXCLUDE_REGEX "/apple|/ios|/linux|/mac|/solaris|/android|/dwarf|/tests|/testdata|/unittests")
    elseif(APPLE)
        set(HEADER_EXCLUDE_REGEX "/apple|/ios|/linux|/windows|/solaris|/android|/dwarf|/tests|/testdata|/unittests|/*proj|/gcov")
    else()
        set(HEADER_EXCLUDE_REGEX "/apple|/ios|/client/linux/data|/client/linux/sender|/windows|/mac|/solaris|/android|/dwarf|/tests|/testdata|/unittests")
    endif()
    install(
        DIRECTORY src/client src/common src/google_breakpad
        DESTINATION include/
        FILES_MATCHING
        PATTERN "*.h"
        REGEX ${HEADER_EXCLUDE_REGEX} EXCLUDE
    )
endif()

install(
    EXPORT unofficial-breakpad-targets
    FILE unofficial-breakpad-config.cmake
    NAMESPACE unofficial::breakpad::
    DESTINATION share/unofficial-breakpad
)
