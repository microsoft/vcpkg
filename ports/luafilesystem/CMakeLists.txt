cmake_minimum_required(VERSION 3.11)
project(luafilesystem)

find_path(LUA_INCLUDE_DIR lua.h PATH_SUFFIXES lua)
find_library(LUA_LIBRARY lua)
set(LFS_INCLUDES ${LUA_INCLUDE_DIR})
set(LFS_LIBRARIES ${LUA_LIBRARY})

add_library(lfs src/lfs.h src/lfs.c src/lfs.def)

target_include_directories(lfs PRIVATE ${LFS_INCLUDES})
target_link_libraries(lfs PRIVATE ${LFS_LIBRARIES})
target_include_directories(lfs INTERFACE $<INSTALL_INTERFACE:include/luafilesystem>)

# If BUILD_SHARED_LIBS is ON, then add_library() will build a DLL and we can copy that to lib/lua/
# to be loaded by the Lua interpreter, otherwise the DLL as an extra target for that purpose.

if(BUILD_SHARED_LIBS)
  if(WIN32)
    add_custom_command(TARGET lfs POST_BUILD
      COMMAND "${CMAKE_COMMAND}" -E copy
        "$<TARGET_FILE:lfs>"
        "${CMAKE_INSTALL_PREFIX}/lib/lua/lfs.dll")
  else()
    add_custom_command(TARGET lfs POST_BUILD
      COMMAND "${CMAKE_COMMAND}" -E copy
        "$<TARGET_FILE:lfs>"
        "${CMAKE_INSTALL_PREFIX}/lib/lua/lfs.so")
  endif()
else()
  add_library(lfs-module MODULE src/lfs.h src/lfs.c src/lfs.def)

  target_include_directories(lfs-module PRIVATE ${LFS_INCLUDES})
  target_link_libraries(lfs-module PRIVATE ${LFS_LIBRARIES})

  set_target_properties(lfs-module PROPERTIES OUTPUT_NAME "lfs")
  set_target_properties(lfs-module PROPERTIES PREFIX "")

  install(TARGETS lfs-module
    RUNTIME DESTINATION lib/lua
    LIBRARY DESTINATION lib/lua)
endif()

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

install(FILES "${CMAKE_CURRENT_SOURCE_DIR}/src/lfs.h" DESTINATION "include/luafilesystem")

install(
  FILES "${CMAKE_CURRENT_BINARY_DIR}/unofficial-${PROJECT_NAME}-config.cmake"
  DESTINATION "share/unofficial-${PROJECT_NAME}"
)

install(
  EXPORT      "unofficial-${PROJECT_NAME}-targets"
  NAMESPACE   "unofficial::${PROJECT_NAME}::"
  DESTINATION "share/unofficial-${PROJECT_NAME}")
