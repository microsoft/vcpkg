cmake_minimum_required(VERSION 3.11)
project(luafilesystem)

find_path(LUA_INCLUDE_DIR lua.h PATH_SUFFIXES lua)
find_library(LUA_LIBRARY lua)
set(LFS_INCLUDES ${LUA_INCLUDE_DIR})
set(LFS_LIBRARIES ${LUA_LIBRARY})

add_library(lfs src/lfs.h src/lfs.c src/lfs.def)

target_include_directories(lfs PRIVATE ${LFS_INCLUDES})
target_link_libraries(lfs PRIVATE ${LFS_LIBRARIES})

install(TARGETS lfs
    EXPORT "unofficial-${PROJECT_NAME}-targets"
    RUNTIME DESTINATION bin
    LIBRARY DESTINATION lib
    ARCHIVE DESTINATION lib)

include(CMakePackageConfigHelpers)

configure_package_config_file(
  "${CMAKE_CURRENT_SOURCE_DIR}/unofficial-${PROJECT_NAME}-config.cmake.in"
  "${CMAKE_CURRENT_BINARY_DIR}/unofficial-${PROJECT_NAME}-config.cmake"
  INSTALL_DESTINATION "share/unofficial-${PROJECT_NAME}"
)

set(VERSION_FILE_PATH "${CMAKE_CURRENT_BINARY_DIR}/unofficial-${PROJECT_NAME}-config-version.cmake")
write_basic_package_version_file(
  "${VERSION_FILE_PATH}"
  VERSION       "${LFS_VERSION}"
  COMPATIBILITY SameMajorVersion
)

install(
  FILES "${CMAKE_CURRENT_BINARY_DIR}/unofficial-${PROJECT_NAME}-config.cmake"
  DESTINATION "share/unofficial-${PROJECT_NAME}"
)

install(
  EXPORT      "unofficial-${PROJECT_NAME}-targets"
  NAMESPACE   "unofficial::${PROJECT_NAME}::"
  DESTINATION "share/unofficial-${PROJECT_NAME}")
