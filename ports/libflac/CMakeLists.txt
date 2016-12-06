cmake_minimum_required(VERSION 2.6)
cmake_policy(SET CMP0005 NEW) # do not escape preprocessor defines

project(libflac)

if(NOT DEFINED LIBFLAC_OGG_LIB OR NOT DEFINED LIBFLAC_OGG_INCLUDES)
    message(FATAL_ERROR "Ogg library required")
endif()

if(NOT DEFINED LIBFLAC_ARCHITECTURE)
    message(FATAL_ERROR "Target architecture not specified")
endif()

file(GLOB LIBFLAC_SOURCES
    ${PROJECT_SOURCE_DIR}/src/libFLAC/*.c
    ${PROJECT_SOURCE_DIR}/src/share/win_utf8_io/win_utf8_io.c)

file(GLOB LIBFLACXX_SOURCES
    ${PROJECT_SOURCE_DIR}/src/libFLAC++/*.cpp)

include_directories(${PROJECT_SOURCE_DIR}/include)
include_directories(${PROJECT_SOURCE_DIR}/src/libFLAC/include)
include_directories(${LIBFLAC_OGG_INCLUDES})

if(NOT LIBFLAC_ARCHITECTURE MATCHES arm)
    add_definitions(-DFLAC__SSE_OS)
    add_definitions(-DFLAC__HAS_X86INTRIN)
endif()

if(LIBFLAC_ARCHITECTURE MATCHES x86)
    add_definitions(-DFLAC__CPU_IA32)
elseif(LIBFLAC_ARCHITECTURE MATCHES x64)
    add_definitions(-DFLAC__CPU_X86_64)
endif()

if(CMAKE_BUILD_TYPE MATCHES Debug)
    add_definitions(-DFLAC__OVERFLOW_DETECT)
endif()

add_definitions(-DVERSION="1.3.1")
add_definitions(-DFLAC__HAS_OGG)
add_definitions(-DFLAC__ALIGN_MALLOC_DATA) # 32 byte boundary
add_definitions(-D_CRT_SECURE_NO_WARNINGS)
add_definitions(-D_CRT_NONSTDC_NO_WARNINGS)

add_library(libFLAC ${LIBFLAC_SOURCES})
add_library(libFLACXX ${LIBFLACXX_SOURCES})

set_target_properties(libFLAC PROPERTIES OUTPUT_NAME flac)
set_target_properties(libFLACXX PROPERTIES OUTPUT_NAME flac++)

target_link_libraries(libFLAC ${LIBFLAC_OGG_LIB})
target_link_libraries(libFLACXX libFLAC)

if(BUILD_SHARED_LIBS)
    set_target_properties(libFLACXX PROPERTIES COMPILE_FLAGS -DFLACPP_API_EXPORTS)
    set_target_properties(libFLAC PROPERTIES COMPILE_FLAGS -DFLAC_API_EXPORTS)
else()
    add_definitions(-DFLAC__NO_DLL)
endif()

install(TARGETS libFLAC libFLACXX
    RUNTIME DESTINATION bin
    ARCHIVE DESTINATION lib
    LIBRARY DESTINATION lib)

if(NOT DEFINED LIBFLAC_SKIP_HEADERS)
    install(DIRECTORY ${PROJECT_SOURCE_DIR}/include/FLAC/
        DESTINATION include/FLAC
        FILES_MATCHING PATTERN "*.h")
    install(DIRECTORY ${PROJECT_SOURCE_DIR}/include/FLAC++/
        DESTINATION include/FLAC++
        FILES_MATCHING PATTERN "*.h")
endif()
