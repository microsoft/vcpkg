cmake_minimum_required(VERSION 3.9)
project(mujs VERSION 1.3.2)

if(MSVC)
  add_compile_options(/W3 /wd4005 /wd4996 /wd4018 -D_CRT_SECURE_NO_WARNINGS)
endif()

file(GLOB mujs_sources js*.c utf*.c regexp.c)

include_directories(.)

add_library(mujs ${mujs_sources})

target_include_directories(mujs PUBLIC "$<INSTALL_INTERFACE:include>")

# Add CMake find_package() integration
set(CONFIG_INSTALL_DIR "${CMAKE_INSTALL_LIBDIR}/cmake/${PROJECT_NAME}")
set(PROJECT_CONFIG "${CMAKE_CURRENT_BINARY_DIR}/${PROJECT_NAME}Config.cmake")
set(TARGETS_EXPORT_NAME "unofficial-${PROJECT_NAME}Targets")
set(NAMESPACE "unofficial::mujs::")

install(
  TARGETS mujs
  EXPORT ${TARGETS_EXPORT_NAME}
  RUNTIME DESTINATION bin
  LIBRARY DESTINATION lib
  ARCHIVE DESTINATION lib
)

export(TARGETS mujs NAMESPACE ${NAMESPACE} FILE mujsTargets.cmake)

include(CMakePackageConfigHelpers)
write_basic_package_version_file(
    mujsConfigVersion.cmake
    VERSION ${PACKAGE_VERSION}
    COMPATIBILITY AnyNewerVersion
)

configure_package_config_file("mujsConfig.cmake.in" "${PROJECT_CONFIG}" INSTALL_DESTINATION "${CONFIG_INSTALL_DIR}")
install(FILES "${PROJECT_CONFIG}" DESTINATION "${CONFIG_INSTALL_DIR}")

install(EXPORT ${TARGETS_EXPORT_NAME}
        NAMESPACE ${NAMESPACE}
        DESTINATION "${CONFIG_INSTALL_DIR}")
        
if(NOT DISABLE_INSTALL_HEADERS)
  install(FILES mujs.h DESTINATION include)
endif()
