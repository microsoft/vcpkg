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
)

set(CMAKE_DEBUG_POSTFIX d)

string(COMPARE EQUAL "${CMAKE_BUILD_TYPE}" "Release" DEFAULT_INSTALL_HEADERS)
option(INSTALL_HEADERS "Install header files" ${DEFAULT_INSTALL_HEADERS})

# libbreakpad target
if(NOT CMAKE_SYSTEM_NAME STREQUAL Android)
    file(GLOB_RECURSE LIBBREAKPAD_SOURCES src/processor/*.cc)
    if(WIN32)
        list(FILTER LIBBREAKPAD_SOURCES EXCLUDE REGEX
            "_unittest|synth_minidump|/tests|/testdata|/linux|/mac|/android|/solaris|microdump_stackwalk|minidump_dump|minidump_stackwalk")
    elseif(APPLE)
        list(FILTER LIBBREAKPAD_SOURCES EXCLUDE REGEX
            "_unittest|synth_minidump|/tests|/testdata|/linux|/windows|/android|/solaris|microdump_stackwalk|minidump_dump|minidump_stackwalk")
    else()
        list(FILTER LIBBREAKPAD_SOURCES EXCLUDE REGEX
            "_unittest|synth_minidump|/tests|/testdata|/mac|/windows|/android|/solaris|microdump_stackwalk|minidump_dump|minidump_stackwalk")
    endif()

    find_library(LIBDISASM_LIB NAMES libdisasmd libdisasm)

    add_library(libbreakpad ${LIBBREAKPAD_SOURCES})
    target_link_libraries(libbreakpad PRIVATE ${LIBDISASM_LIB})

    target_include_directories(libbreakpad
        PUBLIC
            $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/src>
            $<INSTALL_INTERFACE:include>
    )

    set(TARGETS libbreakpad)
endif()

# libbreakpad_client target
if(CMAKE_SYSTEM_NAME STREQUAL Android)
    file(READ "android/google_breakpad/Android.mk" android_mk)
    string(REGEX MATCHALL "src/[^\n]*\\.cc" LIBBREAKPAD_CLIENT_SOURCES "${android_mk}")
else()
    if(WIN32)
        file(GLOB_RECURSE LIBBREAKPAD_CLIENT_SOURCES src/client/windows/*.cc src/common/windows/*.cc)
        include_directories("$ENV{VSINSTALLDIR}/DIA SDK/include")
    elseif(APPLE)
        add_definitions(-DHAVE_MACH_O_NLIST_H)
        file(GLOB_RECURSE LIBBREAKPAD_CLIENT_SOURCES src/client/mac/*.cc src/common/mac/*.cc)
        list(APPEND LIBBREAKPAD_CLIENT_SOURCES src/common/mac/MachIPC.mm)
    else()
        add_definitions(-DHAVE_A_OUT_H)
        file(GLOB_RECURSE LIBBREAKPAD_CLIENT_SOURCES src/client/linux/*.cc src/common/linux/*.cc)
    endif()
    file(GLOB LIBBREAKPAD_COMMON_SOURCES src/common/*.cc src/common/*.c src/client/*.cc)
    list(APPEND LIBBREAKPAD_CLIENT_SOURCES ${LIBBREAKPAD_COMMON_SOURCES})
endif()
list(FILTER LIBBREAKPAD_CLIENT_SOURCES EXCLUDE REGEX "/sender|/tests|/unittests|/testcases|_unittest|_test")
if(WIN32)
    list(FILTER LIBBREAKPAD_CLIENT_SOURCES EXCLUDE REGEX "language.cc|path_helper.cc|stabs_to_module.cc|stabs_reader.cc|minidump_file_writer.cc")
elseif(NOT APPLE)
    try_compile(HAVE_GETCONTEXT ${CMAKE_BINARY_DIR}/check_getcontext ${CMAKE_CURRENT_LIST_DIR}/check_getcontext.cc OUTPUT_VARIABLE BUILD_OUT)
    if (NOT HAVE_GETCONTEXT)
        enable_language(ASM)
        list(APPEND LIBBREAKPAD_CLIENT_SOURCES src/common/linux/breakpad_getcontext.S)
    endif()
endif()

add_library(libbreakpad_client ${LIBBREAKPAD_CLIENT_SOURCES})
if(WIN32)
    target_link_libraries(libbreakpad_client PRIVATE wininet.lib)
elseif(APPLE)
    find_library(CoreFoundation_FRAMEWORK CoreFoundation)
    target_link_libraries(libbreakpad_client PRIVATE ${CoreFoundation_FRAMEWORK})
else()
    find_library(PTHREAD_LIBRARIES pthread)
    if(PTHREAD_LIBRARIES)
        target_link_libraries(libbreakpad_client PRIVATE ${PTHREAD_LIBRARIES})
    endif()
    if (HAVE_GETCONTEXT)
        target_compile_definitions(libbreakpad_client PRIVATE HAVE_GETCONTEXT=1)
    endif()
endif()

target_include_directories(libbreakpad_client
    PUBLIC
        $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/src>
        $<INSTALL_INTERFACE:include>
)
list(APPEND TARGETS libbreakpad_client)

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
        set(HEADER_EXCLUDE_REGEX "/apple|/ios|/linux|/windows|/solaris|/android|/dwarf|/tests|/testdata|/unittests|/sender|/testapp|/*proj|/gcov")
    else()
        set(HEADER_EXCLUDE_REGEX "/apple|/ios|/windows|/mac|/solaris|/android|/dwarf|/tests|/testdata|/unittests")
        install(
            DIRECTORY src/third_party/lss
            DESTINATION include/third_party
            FILES_MATCHING PATTERN "*.h"
            REGEX "${HEADER_EXCLUDE_REGEX}" EXCLUDE
        )
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
