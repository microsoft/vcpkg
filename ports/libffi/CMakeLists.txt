cmake_minimum_required(VERSION 3.9)
project(libffi C ASM)

set(CMAKE_SHARED_LIBRARY_PREFIX)
set(CMAKE_STATIC_LIBRARY_PREFIX)

if(NOT CMAKE_SYSTEM_PROCESSOR)
    set(CMAKE_SYSTEM_PROCESSOR "${CMAKE_HOST_SYSTEM_PROCESSOR}")
endif()

# config variables for ffi.h.in
set(VERSION 3.1)

set(KNOWN_PROCESSORS x86 x86_64 AMD64 ARM ARM64 i386)

if(NOT CMAKE_SYSTEM_PROCESSOR IN_LIST KNOWN_PROCESSORS)
    message(FATAL_ERROR "Unknown processor: ${CMAKE_SYSTEM_PROCESSOR}")
endif()

if(CMAKE_SYSTEM_PROCESSOR MATCHES "ARM")
    set(TARGET ARM)
elseif(CMAKE_SYSTEM_NAME MATCHES "BSD" AND CMAKE_SIZEOF_VOID_P EQUAL 4)
    set(TARGET X86_FREEBSD)
elseif(CMAKE_SYSTEM_NAME MATCHES "Windows" AND CMAKE_SIZEOF_VOID_P EQUAL 4)
    set(TARGET X86_WIN32)
elseif(CMAKE_SYSTEM_NAME MATCHES "Windows" AND CMAKE_SIZEOF_VOID_P EQUAL 8)
    set(TARGET X86_WIN64)
elseif(CMAKE_SYSTEM_NAME MATCHES "Darwin")
    set(TARGET X86_DARWIN)
elseif(CMAKE_SIZEOF_VOID_P EQUAL 8)
    set(TARGET X86_64)
elseif(CMAKE_SIZEOF_VOID_P EQUAL 4)
    set(TARGET X86)
else()
    message(FATAL_ERROR "Cannot determine target. Please consult ${CMAKE_CURRENT_SOURCE_DIR}/configure.ac and add your platform to this CMake file.")
endif()

set(HAVE_LONG_DOUBLE 0)
set(HAVE_LONG_DOUBLE_VARIANT 0)
set(FFI_EXEC_TRAMPOLINE_TABLE 0)

# mimic layout of original buildsystem
configure_file(include/ffi.h.in ${CMAKE_BINARY_DIR}/include/ffi.h)
file(COPY ${FFI_CONFIG_FILE} DESTINATION ${CMAKE_BINARY_DIR})
file(COPY src/x86/ffitarget.h DESTINATION ${CMAKE_BINARY_DIR}/include)

include_directories(${CMAKE_BINARY_DIR}/include)
include_directories(${CMAKE_BINARY_DIR})
include_directories(include)

add_definitions(-DHAVE_CONFIG_H)
add_definitions(-DFFI_BUILDING)

set(FFI_SOURCES
    src/x86/ffi.c
    src/closures.c
    src/java_raw_api.c
    src/prep_cif.c
    src/raw_api.c
    src/types.c)

macro(add_assembly ASMFILE)
    get_filename_component(ASMFILE_FULL "${ASMFILE}" ABSOLUTE)
    if(MSVC)
        if(CMAKE_SIZEOF_VOID_P EQUAL 4)
            set(ARCH_ASSEMBLER ml /safeseh)
        else()
            set(ARCH_ASSEMBLER ml64)
        endif()

        get_filename_component(ARCH_ASM_NAME "${ASMFILE_FULL}" NAME_WE)

        execute_process(
            COMMAND ${CMAKE_C_COMPILER} /nologo /EP /I. /Iinclude ${ASMFILE_FULL}
            WORKING_DIRECTORY ${CMAKE_BINARY_DIR}
            OUTPUT_FILE ${ARCH_ASM_NAME}.asm
        )

        # Produced *.asm file could be just added to sources.
        # It works in x64 mode, but for some strange reason MASM returns error code when in x86,
        # (even though it didn't report any errors and correctly generated object file)
        # which in turn causes MSBUILD to stop.
        execute_process(
            COMMAND ${ARCH_ASSEMBLER} /c /Zi ${ARCH_ASM_NAME}.asm
            WORKING_DIRECTORY ${CMAKE_BINARY_DIR}
        )

        list(APPEND FFI_SOURCES ${CMAKE_BINARY_DIR}/${ARCH_ASM_NAME}.obj)
    else()
        list(APPEND FFI_SOURCES ${ASMFILE})
    endif()
endmacro()

if(${TARGET} STREQUAL "X86")
    set(CMAKE_ASM_FLAGS "${CMAKE_ASM_FLAGS} -m32")
endif()

if(${TARGET} STREQUAL "X86")
    add_assembly(src/x86/sysv.S)
    add_assembly(src/x86/win32.S)
elseif(${TARGET} STREQUAL "X86_64")
    list(APPEND FFI_SOURCES src/x86/ffi64.c)
    add_assembly(src/x86/unix64.S)
    add_assembly(src/x86/sysv.S)
elseif(${TARGET} STREQUAL "X86_WIN32")
    add_assembly(src/x86/win32.S)
elseif(${TARGET} STREQUAL "X86_WIN64")
    add_assembly(src/x86/win64.S)
elseif(${TARGET} STREQUAL "X86_DARWIN")
    list(APPEND FFI_SOURCES src/x86/ffi64.c)
    add_assembly(src/x86/darwin.S)
    add_assembly(src/x86/darwin64.S)
else()
    message(FATAL_ERROR "Target not implemented")
endif()

if(CMAKE_BUILD_TYPE STREQUAL "Debug")
    list(APPEND FFI_SOURCES src/debug.c)
    add_definitions(-DFFI_DEBUG)
endif()

add_library(libffi ${FFI_SOURCES})

install(TARGETS libffi
    RUNTIME DESTINATION bin
    ARCHIVE DESTINATION lib
    LIBRARY DESTINATION lib)

if(NOT FFI_SKIP_HEADERS)
    install(FILES
        ${CMAKE_BINARY_DIR}/include/ffi.h
        ${CMAKE_BINARY_DIR}/include/ffitarget.h
        DESTINATION include)
endif()
