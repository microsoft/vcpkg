cmake_minimum_required(VERSION 3.20)
project(libmupdf C)

option(INSTALL_GEN_TOOLS "Install bin2coff and hexdump" OFF)
option(WITH_MUJS "Build with mujs support" OFF)
option(BUILD_MUTHREADS "Build libmuthreads" OFF)
option(BUILD_MUTOOL "Build tool mutool" OFF)
option(BUILD_MUDRAW "Build tool mudraw" OFF)
option(BUILD_MUPDF "Build tool mupdf" OFF)

set(CMAKE_DEBUG_POSTFIX d)

set (CMAKE_RUNTIME_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR})

set(LIBMUPDF_INSTALL_EXTRAS )
if(WIN32)    
    set(GEN_OBJ_EXECUTABLE )
    if (TARGET_TRIPLET STREQUAL x86)
        set(GEN_MODE "32bit")
        set(GEN_SUFFIXES "obj")
        set(EXTRA_ARG )
        set(GEN_OBJ_EXECUTABLE "bin2coff")
    elseif (TARGET_TRIPLET STREQUAL x64)
        set(GEN_MODE "64bit")
        set(GEN_SUFFIXES "obj")
        set(EXTRA_ARG )
        set(GEN_OBJ_EXECUTABLE "bin2coff")
    elseif (TARGET_TRIPLET STREQUAL arm OR TARGET_TRIPLET STREQUAL arm64)
        set(GEN_MODE )
        set(GEN_SUFFIXES "c")
        set(GEN_OBJ_EXECUTABLE "hexdump")
    else()
        message(FATAL_ERROR "Unsupported arch ${TARGET_TRIPLET}")
    endif()
    
    if (GEN_OBJ_EXECUTABLE STREQUAL "hexdump" AND HEXDUMP_EXECUTABLE AND EXISTS ${HEXDUMP_EXECUTABLE})
        set(GEN_OBJ_EXECUTABLE ${HEXDUMP_EXECUTABLE})
    elseif (GEN_OBJ_EXECUTABLE STREQUAL "bin2coff" AND BIN2COFF_EXECUTABLE AND EXISTS ${BIN2COFF_EXECUTABLE})
        set(GEN_OBJ_EXECUTABLE ${BIN2COFF_EXECUTABLE})
    else()
        add_executable(bin2coff scripts/bin2coff.c)
        add_executable(hexdump scripts/hexdump.c)
        set(CUSTOM_DEPS "${GEN_OBJ_EXECUTABLE}")
    endif()
    
    file(GLOB_RECURSE FONT_FILES "./resources/fonts/*.ttf" "./resources/fonts/*.ttc" "./resources/fonts/*.otf" "./resources/fonts/*.cff")
    foreach (ONE_FILE IN LISTS FONT_FILES)
        get_filename_component(ONE_FILE_NO_PATH ${ONE_FILE} NAME)
        get_filename_component(ONE_FILE_NAME ${ONE_FILE} NAME_WLE)
        get_filename_component(ONE_FILE_EXT ${ONE_FILE_NO_PATH} LAST_EXT)
        string(REPLACE "." "" ONE_FILE_EXT ${ONE_FILE_EXT})
        set(ONE_PBJ_FILES "${CMAKE_BINARY_DIR}/gen_objs/${ONE_FILE_NO_PATH}.${GEN_SUFFIXES}")
        list(APPEND GEN_OBJ_FILES "${ONE_PBJ_FILES}")
        
        if (GEN_OBJ_EXECUTABLE MATCHES "bin2coff")
            add_custom_command(
                OUTPUT ${ONE_PBJ_FILES}
                COMMAND "${GEN_OBJ_EXECUTABLE}" "${ONE_FILE}" "${ONE_PBJ_FILES}" "_binary_${ONE_FILE_NAME}_${ONE_FILE_EXT}" "${GEN_MODE}"
                WORKING_DIRECTORY "${CMAKE_BINARY_DIR}"
                DEPENDS ${CUSTOM_DEPS}
            )
        else()
            add_custom_command(
                OUTPUT ${ONE_PBJ_FILES}
                COMMAND "${GEN_OBJ_EXECUTABLE}" -s "${ONE_PBJ_FILES}" "${ONE_FILE}"
                WORKING_DIRECTORY "${CMAKE_BINARY_DIR}"
                DEPENDS ${CUSTOM_DEPS}
            )
        endif()
    endforeach()
    set_source_files_properties(${GEN_OBJ_FILES} PROPERTIES GENERATED TRUE)
    
    if (INSTALL_GEN_TOOLS)
        list(APPEND LIBMUPDF_INSTALL_EXTRAS bin2coff hexdump)
    endif()
else()
    find_program(MAKE_EXE NAMES make REQUIRED)
    execute_process(
        COMMAND ${MAKE_EXE} "generate"
        WORKING_DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}"
    )
endif()

find_package(freetype NO_MODULE REQUIRED)
find_package(JPEG REQUIRED)
find_package(harfbuzz CONFIG REQUIRED)
find_package(ZLIB REQUIRED)
find_package(OpenJPEG CONFIG REQUIRED)
find_package(lcms CONFIG REQUIRED)

find_library(JBIG2DEC_LIB NAMES jbig2decd jbig2dec)
if (JBIG2DEC_LIB_NOTFOUND)
    message(FATAL_ERROR "Dependency jbig2dec not found.")
endif()

find_library(GUMBO_LIBRARIES gumbo)
if (GUMBO_LIBRARIES_NOTFOUND)
    message(FATAL_ERROR "Dependency gumbo not found.")
endif()

if (WITH_MUJS)
    file(GLOB_RECURSE MUJS_SOURCES "thirdparty/mujs/*.c")
    add_library(mujs "${MUJS_SOURCES}")
    target_include_directories(mujs PUBLIC thirdparty/mujs)
    if (MSVC)
        target_compile_options(mujs PRIVATE /wd4996)
    endif()
    
    list(APPEND LIBMUPDF_INSTALL_EXTRAS mujs)
    
    set(MUJS_EXTRA_DEFINE FZ_ENABLE_JS=1)
else()
    set(MUJS_EXTRA_DEFINE FZ_ENABLE_JS=0)
endif()

file(GLOB_RECURSE LIBMUPDF_SOURCES "source/*.c" "generated/*.c")
list(FILTER LIBMUPDF_SOURCES EXCLUDE REGEX "source/helpers/[a-z]*\\.c$")
list(FILTER LIBMUPDF_SOURCES EXCLUDE REGEX "source/tools/[a-z]*\\.c$")
list(FILTER LIBMUPDF_SOURCES EXCLUDE REGEX "source/tests/.*.c$")

add_library(libmupdf "${LIBMUPDF_SOURCES}" "${GEN_OBJ_FILES}")
if(WIN32)
  foreach (ONE_FILE IN LISTS GEN_OBJ_FILES)
    list(APPEND LIBMUPDF_SOURCES "${ONE_FILE}")
  endforeach()
endif()

if(WIN32)
  target_compile_definitions(libmupdf PRIVATE -DSHARE_JPEG ${MUJS_EXTRA_DEFINE} FZ_ENABLE_ICC=0)
else()
  target_compile_definitions(libmupdf PRIVATE -DSHARE_JPEG ${MUJS_EXTRA_DEFINE} FZ_ENABLE_ICC=0 HAVE_PTHREAD=1)
endif()
target_include_directories(libmupdf
  PUBLIC
    include
  PRIVATE
    generated
    ${JPEG_INCLUDE_DIR}
)
target_link_libraries(libmupdf PRIVATE
  openjp2
  freetype
  lcms2::lcms2
  harfbuzz::harfbuzz
  ${JPEG_LIBRARIES}
  ${JBIG2DEC_LIB}
  ${GUMBO_LIBRARIES}
  ZLIB::ZLIB
)

if (WITH_MUJS)
    target_link_libraries(libmupdf PRIVATE mujs)
endif()

if (BUILD_MUTHREADS)
    file(GLOB_RECURSE MUTHREADS_SOURCES "source/helpers/mu-threads/*.c")
    add_library(libmuthreads "${MUTHREADS_SOURCES}")
    target_include_directories(libmuthreads PRIVATE include)
    target_compile_definitions(libmuthreads PRIVATE MEMENTO=1)
    if (MSVC)
        target_compile_definitions(libmuthreads PRIVATE _CRT_SECURE_NO_WARNINGS)
    endif()
    
    list(APPEND LIBMUPDF_INSTALL_EXTRAS libmuthreads)
endif()

if (BUILD_MUDRAW)
    set(MUDRAW_SOURCES "${CMAKE_SOURCE_DIR}/source/tools/mudraw.c")
    add_executable(mudraw "${MUDRAW_SOURCES}")
    target_compile_definitions(mudraw PRIVATE MUDRAW_STANDALONE)
    target_include_directories(mudraw PRIVATE include)
    target_link_libraries(mudraw PRIVATE libmupdf)
    
    list(APPEND LIBMUPDF_INSTALL_EXTRAS mudraw)
endif()

if (BUILD_MUTOOL)
    file(GLOB_RECURSE LIBMUTOOL_SOURCES "source/tools/*.c")
    list(FILTER LIBMUTOOL_SOURCES EXCLUDE REGEX "source/tools/muraster.c")
    list(FILTER LIBMUTOOL_SOURCES EXCLUDE REGEX "source/tools/mutool.c")
    message("LIBMUTOOL_SOURCES: ${LIBMUTOOL_SOURCES}")
    add_library(libmutool "${LIBMUTOOL_SOURCES}")
    if (MSVC)
        target_compile_definitions(libmutool PRIVATE _CRT_SECURE_NO_WARNINGS)
    endif()
    target_compile_definitions(libmutool PRIVATE ${MUJS_EXTRA_DEFINE})
    target_include_directories(libmutool PRIVATE include)
    if (WITH_MUJS)
        target_link_libraries(libmutool PRIVATE mujs)
    endif()
    
    set(MUTOOL_SOURCES "${CMAKE_SOURCE_DIR}/source/tools/mutool.c")
    add_executable(mutool "${MUTOOL_SOURCES}")
    target_include_directories(mutool PRIVATE include)
    target_link_libraries(mutool PRIVATE libmutool libmupdf)
    
    list(APPEND LIBMUPDF_INSTALL_EXTRAS mutool)
endif()

if (BUILD_MUPDF AND WIN32)
    list(APPEND MUPDF_SOURCES
        "${CMAKE_SOURCE_DIR}/platform/x11/pdfapp.h"
        "${CMAKE_SOURCE_DIR}/platform/x11/pdfapp.c"
        "${CMAKE_SOURCE_DIR}/platform/x11/win_main.c"
    )
    set(MUPDF_RES "${CMAKE_SOURCE_DIR}/platform/x11/win_res.rc")
    add_executable(mupdf WIN32 "${MUPDF_SOURCES}" "${MUPDF_RES}")
    
    target_compile_options(mupdf PRIVATE "/ENTRY:\"mainCRTStartup\"")
    target_include_directories(mupdf PRIVATE include)
    target_link_libraries(mupdf PRIVATE libmupdf)
    
    list(APPEND LIBMUPDF_INSTALL_EXTRAS mupdf)
endif()

install(DIRECTORY ${CMAKE_SOURCE_DIR}/include DESTINATION include)

install(TARGETS libmupdf ${LIBMUPDF_INSTALL_EXTRAS}
  RUNTIME DESTINATION bin
  LIBRARY DESTINATION lib
  ARCHIVE DESTINATION lib
)

if(BUILD_EXAMPLES)
  add_executable(mu-office-test source/tests/mu-office-test.c)
  target_link_libraries(mu-office-test PRIVATE libmupdf)
endif()
