cmake_minimum_required(VERSION 3.12)

file(READ ${CMAKE_CURRENT_SOURCE_DIR}/configure.ac CONFIGURE_AC_CONTENT)
string(REGEX MATCH "AC_INIT\\(\\[file\\],\\[([0-9]+\\.[0-9]+)\\]" _ ${CONFIGURE_AC_CONTENT})
unset(CONFIGURE_AC_CONTENT)

project(file VERSION ${CMAKE_MATCH_1})

option(FILE_TESTS "Enable file tests" OFF)

# Get library directory for multiarch linux distros
include(GNUInstallDirs)

list(APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_SOURCE_DIR}/cmake/Modules")
set(targets)
find_package(PCRE2 CONFIG REQUIRED COMPONENTS 8BIT)
if(WIN32 AND NOT MINGW)
  find_package(unofficial-getopt-win32 CONFIG REQUIRED)
endif()

set(LIBMAGIC_SOURCE_DIR "${CMAKE_CURRENT_SOURCE_DIR}/src")
set(LIBMAGIC_TEST_DIR "${CMAKE_CURRENT_SOURCE_DIR}/tests")

set(WIN_COMPAT_SOURCES
  ${LIBMAGIC_SOURCE_DIR}/asctime_r.c
  ${LIBMAGIC_SOURCE_DIR}/asprintf.c
  ${LIBMAGIC_SOURCE_DIR}/ctime_r.c
  ${LIBMAGIC_SOURCE_DIR}/dprintf.c
  ${LIBMAGIC_SOURCE_DIR}/getline.c
  ${LIBMAGIC_SOURCE_DIR}/gmtime_r.c
  ${LIBMAGIC_SOURCE_DIR}/localtime_r.c
  ${LIBMAGIC_SOURCE_DIR}/pread.c
  ${LIBMAGIC_SOURCE_DIR}/strcasestr.c
  # ${LIBMAGIC_SOURCE_DIR}/strlcat.c
  # ${LIBMAGIC_SOURCE_DIR}/strlcpy.c
  ${LIBMAGIC_SOURCE_DIR}/vasprintf.c
  ${LIBMAGIC_SOURCE_DIR}/fmtcheck.c
  ${LIBMAGIC_SOURCE_DIR}/magic.def
)

if(WIN32)
  set(LIBMAGIC_SOURCE_FILES ${WIN_COMPAT_SOURCES})
else()
  set(LIBMAGIC_SOURCE_FILES)
endif()

list(APPEND LIBMAGIC_SOURCE_FILES
  ${LIBMAGIC_SOURCE_DIR}/apprentice.c
  ${LIBMAGIC_SOURCE_DIR}/apptype.c
  ${LIBMAGIC_SOURCE_DIR}/ascmagic.c
  ${LIBMAGIC_SOURCE_DIR}/buffer.c
  ${LIBMAGIC_SOURCE_DIR}/cdf.c
  ${LIBMAGIC_SOURCE_DIR}/cdf_time.c
  ${LIBMAGIC_SOURCE_DIR}/compress.c
  ${LIBMAGIC_SOURCE_DIR}/der.c
  ${LIBMAGIC_SOURCE_DIR}/encoding.c
  ${LIBMAGIC_SOURCE_DIR}/fmtcheck.c
  ${LIBMAGIC_SOURCE_DIR}/fsmagic.c
  ${LIBMAGIC_SOURCE_DIR}/funcs.c
  ${LIBMAGIC_SOURCE_DIR}/is_json.c
  ${LIBMAGIC_SOURCE_DIR}/is_simh.c
  ${LIBMAGIC_SOURCE_DIR}/is_tar.c
  ${LIBMAGIC_SOURCE_DIR}/magic.c
  ${LIBMAGIC_SOURCE_DIR}/print.c
  ${LIBMAGIC_SOURCE_DIR}/readcdf.c
  ${LIBMAGIC_SOURCE_DIR}/readelf.c
  ${LIBMAGIC_SOURCE_DIR}/softmagic.c
  # ${LIBMAGIC_SOURCE_DIR}/strlcat.c
  # ${LIBMAGIC_SOURCE_DIR}/strlcpy.c
  ${LIBMAGIC_SOURCE_DIR}/is_csv.c
)
if(NOT APPLE)
list(APPEND LIBMAGIC_SOURCE_FILES
  ${LIBMAGIC_SOURCE_DIR}/strlcat.c
  ${LIBMAGIC_SOURCE_DIR}/strlcpy.c
)
endif()

# replace the version in the magic.h.in and write it to magic.h
FILE(READ ${LIBMAGIC_SOURCE_DIR}/magic.h.in MAGIC_H_CONTENT)
STRING(REPLACE "." "" FILE_VERSION_WITHOUT_DOT "${CMAKE_PROJECT_VERSION}")
STRING(REPLACE "X.YY" ${FILE_VERSION_WITHOUT_DOT} MAGIC_H_CONTENT_NEW "${MAGIC_H_CONTENT}")
FILE(WRITE ${LIBMAGIC_SOURCE_DIR}/magic.h "${MAGIC_H_CONTENT_NEW}")

add_compile_definitions(HAVE_CONFIG_H VERSION="${CMAKE_PROJECT_VERSION}")
if(WIN32)
  add_compile_definitions(WIN32_LEAN_AND_MEAN WIN32)
endif()

add_library(libmagic ${LIBMAGIC_SOURCE_FILES})
set(targets ${targets} libmagic)

target_link_libraries(libmagic PRIVATE PCRE2::POSIX)

target_include_directories(libmagic
  PUBLIC
    "$<BUILD_INTERFACE:${LIBMAGIC_SOURCE_DIR}>"
    "$<INSTALL_INTERFACE:include>"
)

if(WIN32)
  target_link_libraries(libmagic PRIVATE shlwapi)
endif()

# 'file' CLI
add_executable(file ${LIBMAGIC_SOURCE_DIR}/file.c)
set(targets ${targets} file)
target_link_libraries(file PRIVATE PCRE2::POSIX libmagic)
if (WIN32)
  if (NOT MINGW)
    target_link_libraries(file PRIVATE unofficial::getopt-win32::getopt)
  endif()
  target_link_libraries(file PRIVATE shlwapi)
endif()

if(MSVC)
  target_include_directories(file PRIVATE getopt)
endif()

# Following is the compilation of the magic file
file(GLOB MAGIC_FRAGMENTS magic/Magdir/*)

# Prepare a temporary file to combine the magic fragments:
set(MAGIC_FRAGMENTS_FILE ${CMAKE_CURRENT_BINARY_DIR}/magic)
file(WRITE ${MAGIC_FRAGMENTS_FILE} "")

# Call the "cat" function for each input file
foreach(MAGIC_FRAGMENT ${MAGIC_FRAGMENTS})
  file(APPEND ${MAGIC_FRAGMENTS_FILE} "############## ${MAGIC_FRAGMENT} ##############\n")
  file(READ ${MAGIC_FRAGMENT} MAGIC_FRAGMENT_CONTENTS)
  file(APPEND ${MAGIC_FRAGMENTS_FILE} "${MAGIC_FRAGMENT_CONTENTS}\n")
  unset(MAGIC_FRAGMENT_CONTENTS)
endforeach()

# Include module with function 'configure_package_config_file'
include(CMakePackageConfigHelpers)

set(PORT_NAME unofficial-libmagic)
set(TARGETS_EXPORT_NAME ${PORT_NAME}-targets)

install(FILES ${MAGIC_FRAGMENTS_FILE} DESTINATION ${CMAKE_INSTALL_DATAROOTDIR}/libmagic/misc)

install(FILES ${LIBMAGIC_SOURCE_DIR}/magic.h DESTINATION ${CMAKE_INSTALL_INCLUDEDIR})

install(TARGETS ${targets}
        EXPORT ${TARGETS_EXPORT_NAME}
        RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
        LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
        ARCHIVE DESTINATION ${CMAKE_INSTALL_LIBDIR}
        INCLUDES DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}
)
install(EXPORT ${TARGETS_EXPORT_NAME}
        FILE ${TARGETS_EXPORT_NAME}.cmake
        DESTINATION ${CMAKE_INSTALL_LIBDIR}/cmake/${PORT_NAME}
        NAMESPACE unofficial::libmagic::
        )
configure_package_config_file(
  ${PORT_NAME}-config.cmake.in
  ${PORT_NAME}-config.cmake
  INSTALL_DESTINATION ${CMAKE_INSTALL_LIBDIR}/cmake/${PORT_NAME})
write_basic_package_version_file(
  ${PORT_NAME}-config-version.cmake
  VERSION ${CMAKE_PROJECT_VERSION}
  COMPATIBILITY SameMajorVersion)
install(FILES
        ${CMAKE_BINARY_DIR}/${PORT_NAME}-config.cmake
        ${CMAKE_BINARY_DIR}/${PORT_NAME}-config-version.cmake
        DESTINATION ${CMAKE_INSTALL_LIBDIR}/cmake/${PORT_NAME})
