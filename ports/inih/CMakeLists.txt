cmake_minimum_required(VERSION 3.19)
project(
  inih
  VERSION ${VERSION}
)

 # Create and install version file
include(CMakePackageConfigHelpers)

set(VERSION_FILE_PATH "${CMAKE_CURRENT_BINARY_DIR}/unofficial-${PROJECT_NAME}ConfigVersion.cmake")
set(CONFIG_FILE_PATH "${CMAKE_CURRENT_BINARY_DIR}/unofficial-${PROJECT_NAME}Config.cmake")
set(INIH_INSTALL_CMAKE_DIR "share/unofficial-${PROJECT_NAME}")

write_basic_package_version_file(
  "${VERSION_FILE_PATH}"
  VERSION       "${PROJECT_VERSION}"
  COMPATIBILITY SameMajorVersion
)

configure_package_config_file( 
    "${CMAKE_CURRENT_LIST_DIR}/unofficial-inihConfig.cmake.in"
    "${CONFIG_FILE_PATH}" 
    INSTALL_DESTINATION "${INIH_INSTALL_CMAKE_DIR}"
    NO_CHECK_REQUIRED_COMPONENTS_MACRO
)

install(FILES 
    "${VERSION_FILE_PATH}"
    "${CONFIG_FILE_PATH}"
    DESTINATION "${INIH_INSTALL_CMAKE_DIR}"
)
