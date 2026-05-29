cmake_minimum_required(VERSION 3.19...3.23)
project(
  openctm
  VERSION 1.0.3
  LANGUAGES C)

find_package(7zip CONFIG REQUIRED)

set(PUBLIC_HEADERS lib/openctm.h lib/openctmpp.h)

add_library(
  openctm
  lib/compressMG1.c
  lib/compressMG2.c
  lib/compressRAW.c
  lib/openctm.c
  lib/stream.c)

target_include_directories(
  openctm
  PUBLIC $<BUILD_INTERFACE:${CMAKE_CURRENT_LIST_DIR}/lib>
         $<INSTALL_INTERFACE:include>)
target_link_libraries(openctm PRIVATE 7zip::7zip)
target_compile_definitions(openctm PRIVATE OPENCTM_BUILD)
if(NOT BUILD_SHARED_LIBS)
  target_compile_definitions(openctm PUBLIC OPENCTM_STATIC)
endif()
target_compile_features(openctm PRIVATE c_std_99)
set_target_properties(openctm PROPERTIES C_VISIBILITY_PRESET hidden
                                         PUBLIC_HEADER "${PUBLIC_HEADERS}")

include(GNUInstallDirs)
install(
  TARGETS openctm
  EXPORT unofficial-openctmConfig
  RUNTIME DESTINATION "${CMAKE_INSTALL_BINDIR}"
  ARCHIVE DESTINATION "${CMAKE_INSTALL_LIBDIR}"
  LIBRARY DESTINATION "${CMAKE_INSTALL_LIBDIR}"
  PUBLIC_HEADER DESTINATION "${CMAKE_INSTALL_INCLUDEDIR}" COMPONENT dev)

include(CMakePackageConfigHelpers)
set(VERSION_FILE_PATH "${CMAKE_CURRENT_BINARY_DIR}/unofficial-openctmConfigVersion.cmake")
write_basic_package_version_file(
  "${VERSION_FILE_PATH}"
  VERSION ${PROJECT_VERSION}
  COMPATIBILITY SameMajorVersion)
install(FILES "${VERSION_FILE_PATH}" DESTINATION share/unofficial-openctm)

install(FILES ${PUBLIC_HEADERS} DESTINATION "${CMAKE_INSTALL_INCLUDEDIR}")

install(
  EXPORT unofficial-openctmConfig
  FILE unofficial-openctmConfig.cmake
  NAMESPACE unofficial::openctm::
  DESTINATION share/unofficial-openctm)

export(PACKAGE openctm)
