cmake_minimum_required(VERSION 3.20)
project(libmupdf C)

set(CMAKE_DEBUG_POSTFIX d)

if(WIN32)
  if (CMAKE_CL_64)
    set(GEN_MODE "64bit")
  else()
    set(GEN_MODE "32bit")
  endif()
  set(OBJ2COFF_SRC scripts/bin2coff.c)

  add_executable(obj2coff ${OBJ2COFF_SRC})
  file(GLOB_RECURSE FONT_FILES "./resources/fonts/*.ttf" "./resources/fonts/*.ttc" "./resources/fonts/*.otf" "./resources/fonts/*.cff")
  foreach (ONE_FILE IN LISTS FONT_FILES)
    get_filename_component(ONE_FILE_NO_PATH ${ONE_FILE} NAME)
	list(APPEND GEN_OBJ_FILES "${CMAKE_BINARY_DIR}/gen_objs/${ONE_FILE_NO_PATH}.obj")
  endforeach()
  set_source_files_properties(${GEN_OBJ_FILES} PROPERTIES GENERATED TRUE)
  add_custom_command(
    OUTPUT ${GEN_OBJ_FILES}
    COMMAND "cmd.exe" "/c" "${CMAKE_SOURCE_DIR}/gen_font_objs.bat" "${CMAKE_BINARY_DIR}/obj2coff.exe" "${CMAKE_BINARY_DIR}/gen_objs" "${GEN_MODE}"
	WORKING_DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}"
	DEPENDS obj2coff
  )
else()
  find_program(MAKE_EXE NAMES make REQUIRED)
  execute_process(
    COMMAND ${MAKE_EXE} "generate"
    WORKING_DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}"
  )
endif()


find_package(freetype NO_MODULE REQUIRED)
find_package(JPEG REQUIRED)
find_path(HARFBUZZ_INCLUDE hb.h PATH_SUFFIXES harfbuzz)
find_library(HARFBUZZ_LIBRARIES harfbuzz)
find_package(ZLIB REQUIRED)
find_package(OpenJPEG CONFIG REQUIRED)
find_library(JBIG2DEC_LIB NAMES jbig2decd jbig2dec)

file(GLOB_RECURSE SOURCES "source/*.c" "generated/*.c")
list(FILTER SOURCES EXCLUDE REGEX "source/tools/[a-z]*\\.c$")
list(FILTER SOURCES EXCLUDE REGEX "source/tests/.*.c$")

add_library(libmupdf ${SOURCES} ${GEN_OBJ_FILES})
if(WIN32)
  foreach (ONE_FILE IN LISTS GEN_OBJ_FILES)
    list(APPEND SOURCES ${ONE_FILE})
  endforeach()
endif()


if(WIN32)
  target_compile_definitions(libmupdf PRIVATE -DSHARE_JPEG -DFZ_ENABLE_JS=0 -DFZ_ENABLE_ICC=0)
else()
  target_compile_definitions(libmupdf PRIVATE -DSHARE_JPEG -DFZ_ENABLE_JS=0 -DFZ_ENABLE_ICC=0 -DHAVE_PTHREAD=1)
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

install(TARGETS libmupdf
  RUNTIME DESTINATION bin
  LIBRARY DESTINATION lib
  ARCHIVE DESTINATION lib
)

if(BUILD_EXAMPLES)
  add_executable(mu-office-test source/tests/mu-office-test.c)
  target_link_libraries(mu-office-test PRIVATE libmupdf)
endif()
