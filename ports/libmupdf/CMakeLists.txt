cmake_minimum_required(VERSION 3.9)
project(libmupdf C VERSION 1.19.0) #1.19.0-rc2#1

set(CMAKE_DEBUG_POSTFIX d)

if(WIN32)
  execute_process(
    COMMAND "cmd.exe" "/c" "platform\\win32\\generate.bat"
    WORKING_DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}"
  )
else()
  find_program(MAKE_EXE NAMES make REQUIRED)
  execute_process(
    COMMAND ${MAKE_EXE} "generate"
    WORKING_DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}"
  )
endif() 

file(GLOB_RECURSE SOURCES "source/*.c" "generated/*.c")
list(FILTER SOURCES EXCLUDE REGEX "source/tools/[a-z]*\\.c$")
list(FILTER SOURCES EXCLUDE REGEX "source/tests/.*.c$")
list(FILTER SOURCES EXCLUDE REGEX "source/fitz/output-docx.c")

add_library(libmupdf ${SOURCES})

if(WIN32)
  target_compile_definitions(libmupdf PRIVATE -DSHARE_JPEG -DFZ_ENABLE_JS=0 -DFZ_ENABLE_ICC=0 -DMEMENTO_MUPDF_HACKS -DFZ_ENABLE_DOCX_OUTPUT=0 -DFZ_ENABLE_ODT_OUTPUT=0)
else()
  target_compile_definitions(libmupdf PRIVATE -DHAVE_PTHREAD=1 -DSHARE_JPEG -DFZ_ENABLE_JS=0 -DFZ_ENABLE_ICC=0 -DMEMENTO_MUPDF_HACKS -DFZ_ENABLE_DOCX_OUTPUT=0 -DFZ_ENABLE_ODT_OUTPUT=0)
endif()
target_include_directories(libmupdf
  PUBLIC
    include
  PRIVATE
    generated
    ${JPEG_INCLUDE_DIR}
    ${HARFBUZZ_INCLUDE}
)
target_link_libraries(libmupdf PRIVATE
  openjp2
  freetype
  ${JPEG_LIBRARIES}
  ${HARFBUZZ_LIBRARIES}
  ${JBIG2DEC_LIB}
  ZLIB::ZLIB
)

export(TARGETS libmupdf NAMESPACE libmupdf:: FILE libmupdfTargets.cmake)

install(TARGETS libmupdf
  EXPORT libmupdfTargets
  RUNTIME DESTINATION bin
  LIBRARY DESTINATION lib
  ARCHIVE DESTINATION lib
)

include(CMakePackageConfigHelpers)
write_basic_package_version_file(
    libmupdfConfigVersion.cmake
    VERSION ${PACKAGE_VERSION}
    COMPATIBILITY AnyNewerVersion
)

install(EXPORT libmupdfTargets
        FILE libmupdfTargets.cmake
        NAMESPACE libmupdf::
        DESTINATION lib/cmake/libmupdf
)

configure_file(libmupdfConfig.cmake.in libmupdfConfig.cmake @ONLY)

if(BUILD_EXAMPLES)
  add_executable(mu-office-test source/tests/mu-office-test.c)
  target_link_libraries(mu-office-test PRIVATE libmupdf)
endif()
        