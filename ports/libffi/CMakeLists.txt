cmake_minimum_required(VERSION 3.0)
project(libffi)

# config variables for ffi.h.in
set(VERSION 3.1)
if(CMAKE_SIZEOF_VOID_P EQUAL 4)
    set(TARGET X86_WIN32)
else()
    set(TARGET X86_WIN64)
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
if(BUILD_SHARED_LIBS)
    add_definitions(-DFFI_EXPORT_DATA)
    set(CMAKE_WINDOWS_EXPORT_ALL_SYMBOLS ON)
endif()

if(CMAKE_SIZEOF_VOID_P EQUAL 4)
    set(ARCH_ASM_NAME win32)
    set(ARCH_ASSEMBLER ml /safeseh)
else()
    set(ARCH_ASM_NAME win64)
    set(ARCH_ASSEMBLER ml64)
endif()

execute_process(
    COMMAND cl /nologo /EP /I. /Iinclude ${CMAKE_SOURCE_DIR}/src/x86/${ARCH_ASM_NAME}.S 
    WORKING_DIRECTORY ${CMAKE_BINARY_DIR}
    OUTPUT_FILE ${ARCH_ASM_NAME}.asm)

# Produced *.asm file could be just added to sources.
# It works in x64 mode, but for some strange reason MASM returns error code when in x86,
# (even though it didn't report any errors and correctly generated object file)
# which in turn causes MSBUILD to stop.
execute_process(
    COMMAND ${ARCH_ASSEMBLER} /c /Zi ${ARCH_ASM_NAME}.asm
    WORKING_DIRECTORY ${CMAKE_BINARY_DIR})

set(FFI_SOURCES
    ${CMAKE_BINARY_DIR}/${ARCH_ASM_NAME}.obj
    src/x86/ffi.c
    src/closures.c
    src/java_raw_api.c
    src/prep_cif.c
    src/raw_api.c
    src/types.c)

if(CMAKE_BUILD_TYPE STREQUAL Debug)
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
