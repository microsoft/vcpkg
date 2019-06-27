cmake_minimum_required(VERSION 3.0)
project(libelf C)

file(GLOB_RECURSE SOURCES "${PROJECT_SOURCE_DIR}/*.c")
add_library(libelf SHARED ${SOURCES})
target_include_directories(libelf PRIVATE ${PROJECT_SOURCE_DIR})

if(MSVC)
    target_compile_definitions(libelf PUBLIC HAVE_CONFIG_H)
    set_target_properties(libelf PROPERTIES WINDOWS_EXPORT_ALL_SYMBOLS TRUE)
endif()

include(CMakePackageConfigHelpers)

# Add CMake find_package() integration
set(PROJECT_TARGET_NAME "${PROJECT_NAME}")
set(CONFIG_INSTALL_DIR "${CMAKE_INSTALL_LIBDIR}/cmake/${PROJECT_NAME}")
set(PROJECT_CONFIG "${CMAKE_CURRENT_BINARY_DIR}/generated/${PROJECT_TARGET_NAME}Config.cmake")
set(TARGETS_EXPORT_NAME "${PROJECT_TARGET_NAME}Targets")

# Headers
file(GLOB LIB_INST_HEADERS *.h)
install(FILES ${LIB_INST_HEADERS} DESTINATION include/libelf)
install(FILES libelf.h DESTINATION include)

install(TARGETS libelf
    EXPORT ${TARGETS_EXPORT_NAME}
    RUNTIME DESTINATION bin
    LIBRARY DESTINATION lib
    ARCHIVE DESTINATION lib
    INCLUDES DESTINATION include)

# Generate and install libelfConfig.cmake
configure_package_config_file("Config.cmake.in" "${PROJECT_CONFIG}"
    INSTALL_DESTINATION "${CONFIG_INSTALL_DIR}")
install(FILES "${PROJECT_CONFIG}"
    DESTINATION "${CONFIG_INSTALL_DIR}")

# Generate and install libelfTargets*.cmake
install(EXPORT ${TARGETS_EXPORT_NAME}
    DESTINATION "${CONFIG_INSTALL_DIR}")
