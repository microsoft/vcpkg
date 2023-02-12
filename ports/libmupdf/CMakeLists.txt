cmake_minimum_required(VERSION 3.9)
project(libmupdf LANGUAGES C) #1.21.1

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

find_package(freetype NO_MODULE REQUIRED)
find_package(JPEG REQUIRED)
find_package(harfbuzz CONFIG REQUIRED)
find_package(ZLIB REQUIRED)
find_package(OpenJPEG CONFIG REQUIRED)

file(GLOB_RECURSE SOURCES "source/*.c")
file(GLOB_RECURSE HEADER "source/*.h" "include/*.h")
list(FILTER SOURCES EXCLUDE REGEX "source/tools/[a-z]*\\.c$")
list(FILTER SOURCES EXCLUDE REGEX "source/tests/.*.c$")
list(FILTER SOURCES EXCLUDE REGEX "source/fitz/output-docx.c")

add_library(libmupdf ${SOURCES} ${HEADER})

if(WIN32)
  target_compile_definitions(libmupdf PRIVATE -DSHARE_JPEG -DFZ_ENABLE_JS=0 -DFZ_ENABLE_ICC=0 -DMEMENTO_MUPDF_HACKS -DFZ_ENABLE_DOCX_OUTPUT=0 -DFZ_ENABLE_ODT_OUTPUT=0)
else()
  target_compile_definitions(libmupdf PRIVATE -DHAVE_PTHREAD=1 -DSHARE_JPEG -DFZ_ENABLE_JS=0 -DFZ_ENABLE_ICC=0 -DMEMENTO_MUPDF_HACKS -DFZ_ENABLE_DOCX_OUTPUT=0 -DFZ_ENABLE_ODT_OUTPUT=0)
endif()
#include_directories(include)
target_include_directories(libmupdf
  PUBLIC
    $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/include>
    $<INSTALL_INTERFACE:include>
  PRIVATE
    generated
    ${JPEG_INCLUDE_DIR}
    ${HARFBUZZ_INCLUDE}
)
target_link_libraries(libmupdf PRIVATE
  openjp2
  freetype
  ${JPEG_LIBRARIES}
  harfbuzz::harfbuzz
  ZLIB::ZLIB
)

# Add CMake find_package() integration
set(CONFIG_INSTALL_DIR "${CMAKE_INSTALL_LIBDIR}/cmake/${PROJECT_NAME}")
set(UNOFFICIAL_PROJECT_NAME "unofficial-${PROJECT_NAME}")
set(PROJECT_CONFIG "${CMAKE_CURRENT_BINARY_DIR}/${UNOFFICIAL_PROJECT_NAME}Config.cmake")
set(TARGETS_EXPORT_NAME "unofficial-${PROJECT_NAME}Targets")
set(NAMESPACE "unofficial::libmupdf::")

export(TARGETS ${PROJECT_NAME} NAMESPACE ${NAMESPACE} FILE ${TARGETS_EXPORT_NAME}.cmake)

install(TARGETS ${PROJECT_NAME}
  EXPORT ${TARGETS_EXPORT_NAME}
  RUNTIME DESTINATION bin
  LIBRARY DESTINATION lib
  ARCHIVE DESTINATION lib
  INCLUDES include
)

include(CMakePackageConfigHelpers)
write_basic_package_version_file(
    ${UNOFFICIAL_PROJECT_NAME}ConfigVersion.cmake
    VERSION ${PACKAGE_VERSION}
    COMPATIBILITY AnyNewerVersion
)

configure_package_config_file("libmupdfConfig.cmake.in" "${PROJECT_CONFIG}" INSTALL_DESTINATION "${CONFIG_INSTALL_DIR}")
install(FILES "${PROJECT_CONFIG}" DESTINATION "${CONFIG_INSTALL_DIR}")

install(EXPORT ${TARGETS_EXPORT_NAME}
        NAMESPACE ${NAMESPACE}
        DESTINATION "${CONFIG_INSTALL_DIR}")

if(BUILD_EXAMPLES)
  add_executable(mu-office-test source/tests/mu-office-test.c)
  target_link_libraries(mu-office-test PRIVATE libmupdf)
endif()
        