cmake_minimum_required(VERSION 3.19)
project(keccak-tiny VERSION 2014.09.08 LANGUAGES C)

set(Header_Files "${PROJECT_NAME}.h")
set(Source_Files "${PROJECT_NAME}-unrolled.c")

add_library("${PROJECT_NAME}" "${Header_Files}" "${Source_Files}")

include(GNUInstallDirs)
target_include_directories(
  "${PROJECT_NAME}"
  PUBLIC
  "$<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}>"
  "$<INSTALL_INTERFACE:${CMAKE_INSTALL_INCLUDEDIR}>"
)
target_compile_features("${PROJECT_NAME}" PRIVATE c_std_90)
set_target_properties("${PROJECT_NAME}" PROPERTIES C_VISIBILITY_PRESET hidden
                      PUBLIC_HEADER "${Header_Files}")

install(
  TARGETS                   "${PROJECT_NAME}"
  EXPORT                    "unofficial-${PROJECT_NAME}Config"
  RUNTIME       DESTINATION "${CMAKE_INSTALL_BINDIR}"
  ARCHIVE       DESTINATION "${CMAKE_INSTALL_LIBDIR}"
  LIBRARY       DESTINATION "${CMAKE_INSTALL_LIBDIR}"
  PUBLIC_HEADER DESTINATION "${CMAKE_INSTALL_INCLUDEDIR}"
)

include(CMakePackageConfigHelpers)
set(VERSION_FILE_PATH "${CMAKE_CURRENT_BINARY_DIR}/unofficial-${PROJECT_NAME}ConfigVersion.cmake")
write_basic_package_version_file(
  "${VERSION_FILE_PATH}"
  VERSION       "${PROJECT_VERSION}"
  COMPATIBILITY SameMajorVersion
)
install(FILES "${VERSION_FILE_PATH}" DESTINATION "share/unofficial-${PROJECT_NAME}")

install(FILES ${Header_Files} DESTINATION "${CMAKE_INSTALL_INCLUDEDIR}")

install(
  EXPORT      "unofficial-${PROJECT_NAME}Config"
  FILE        "unofficial-${PROJECT_NAME}Config.cmake"
  NAMESPACE   "unofficial::${PROJECT_NAME}::"
  DESTINATION "share/unofficial-${PROJECT_NAME}")

export(PACKAGE "${PROJECT_NAME}")
