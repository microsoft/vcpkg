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
option(INSTALL_TOOLS "Install tools" OFF)

# libbreakpad target
if(NOT CMAKE_SYSTEM_NAME STREQUAL Android)
    file(GLOB_RECURSE LIBBREAKPAD_SOURCES src/processor/*.cc)
    if(WIN32)
        list(FILTER LIBBREAKPAD_SOURCES EXCLUDE REGEX
            "_unittest|_selftest|synth_minidump|/tests|/testdata|/linux|/mac|/android|/solaris|microdump_stackwalk|minidump_dump|minidump_stackwalk")
    elseif(APPLE)
        list(FILTER LIBBREAKPAD_SOURCES EXCLUDE REGEX
            "_unittest|_selftest|synth_minidump|/tests|/testdata|/linux|/windows|/android|/solaris|microdump_stackwalk|minidump_dump|minidump_stackwalk")
    else()
        list(FILTER LIBBREAKPAD_SOURCES EXCLUDE REGEX
            "_unittest|_selftest|synth_minidump|/tests|/testdata|/mac|/windows|/android|/solaris|microdump_stackwalk|minidump_dump|minidump_stackwalk")
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

if(INSTALL_TOOLS)
    if(LINUX)
        add_executable(microdump_stackwalk
                src/processor/microdump_stackwalk.cc)
        target_link_libraries(microdump_stackwalk PRIVATE libbreakpad libbreakpad_client)
        install(TARGETS microdump_stackwalk DESTINATION bin)

        add_executable(minidump_dump
                src/processor/minidump_dump.cc)
        target_link_libraries(minidump_dump PRIVATE libbreakpad libbreakpad_client)
        install(TARGETS minidump_dump DESTINATION bin)

        add_executable(minidump_stackwalk
                src/processor/minidump_stackwalk.cc)
        target_link_libraries(minidump_stackwalk PRIVATE libbreakpad libbreakpad_client)
        install(TARGETS minidump_stackwalk DESTINATION bin)

        add_executable(core2md
            src/tools/linux/core2md/core2md.cc)
        target_link_libraries(core2md PRIVATE libbreakpad_client)
        install(TARGETS core2md DESTINATION bin)

        add_executable(pid2md
            src/tools/linux/pid2md/pid2md.cc)
        target_link_libraries(pid2md PRIVATE libbreakpad_client)
        install(TARGETS pid2md DESTINATION bin)

        add_executable(dump_syms
            src/common/dwarf_cfi_to_module.cc
            src/common/dwarf_cu_to_module.cc
            src/common/dwarf_line_to_module.cc
            src/common/dwarf_range_list_handler.cc
            src/common/language.cc
            src/common/module.cc
            src/common/path_helper.cc
            src/common/stabs_reader.cc
            src/common/stabs_to_module.cc
            src/common/dwarf/bytereader.cc
            src/common/dwarf/dwarf2diehandler.cc
            src/common/dwarf/dwarf2reader.cc
            src/common/dwarf/elf_reader.cc
            src/common/linux/crc32.cc
            src/common/linux/dump_symbols.cc
            src/common/linux/elf_symbols_to_module.cc
            src/common/linux/elfutils.cc
            src/common/linux/file_id.cc
            src/common/linux/linux_libc_support.cc
            src/common/linux/memory_mapped_file.cc
            src/common/linux/safe_readlink.cc
            src/tools/linux/dump_syms/dump_syms.cc)
        target_link_libraries(dump_syms PRIVATE libbreakpad_client)
        install(TARGETS dump_syms DESTINATION bin)

        add_executable(minidump-2-core
            src/common/linux/memory_mapped_file.cc
            src/tools/linux/md2core/minidump-2-core.cc)
        target_link_libraries(minidump-2-core PRIVATE libbreakpad_client)
        install(TARGETS minidump-2-core DESTINATION bin)

        add_executable(minidump_upload
            src/common/linux/http_upload.cc
            src/tools/linux/symupload/minidump_upload.cc)
        target_link_libraries(minidump_upload PRIVATE libbreakpad_client ${CMAKE_DL_LIBS})
        install(TARGETS minidump_upload DESTINATION bin)

        add_executable(sym_upload
            src/common/linux/http_upload.cc
            src/common/linux/libcurl_wrapper.cc
            src/common/linux/symbol_collector_client.cc
            src/common/linux/symbol_upload.cc
            src/tools/linux/symupload/sym_upload.cc)
        target_link_libraries(sym_upload PRIVATE libbreakpad_client ${CMAKE_DL_LIBS})
        install(TARGETS sym_upload DESTINATION bin)

        add_executable(core_handler
            src/tools/linux/core_handler/core_handler.cc)
        target_link_libraries(core_handler PRIVATE libbreakpad_client)
        install(TARGETS core_handler DESTINATION bin)
    endif()
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
