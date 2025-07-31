# Set policies for this port
set(VCPKG_POLICY_DLLS_WITHOUT_LIBS enabled)
set(VCPKG_POLICY_DLLS_WITHOUT_EXPORTS enabled)
set(VCPKG_POLICY_ALLOW_EMPTY_FOLDERS enabled)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO cloudwu/sproto
    REF 63df1ad8be4a7b295d389afaca7019e86f70d39c
    SHA512 5613a04e6197b6fa00828f457aeee0270a7f4d300df609d62e405123f3623516c5761bd2c6b0b8e21be12aa30ca3288ae6307121bf8461535ad8c3efe9a750a2
    HEAD_REF master
)

# Since sproto uses Makefile, we need to create a CMakeLists.txt
file(WRITE "${SOURCE_PATH}/CMakeLists.txt" "
cmake_minimum_required(VERSION 3.14)
project(sproto C)

set(CMAKE_C_STANDARD 99)

# Add the main library
add_library(sproto sproto.c)
target_include_directories(sproto PUBLIC
    $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}>
    $<INSTALL_INTERFACE:include>
)

# Install library and headers
install(TARGETS sproto 
    EXPORT sproto-targets
    LIBRARY DESTINATION lib
    ARCHIVE DESTINATION lib
    RUNTIME DESTINATION bin
)

install(FILES sproto.h DESTINATION include)

# Install CMake config files
install(EXPORT sproto-targets
    FILE sproto-targets.cmake
    NAMESPACE sproto::
    DESTINATION share/sproto
)

# Create and install config file
include(CMakePackageConfigHelpers)
configure_package_config_file(
    \"\${CMAKE_CURRENT_LIST_DIR}/sproto-config.cmake.in\"
    \"\${CMAKE_CURRENT_BINARY_DIR}/sproto-config.cmake\"
    INSTALL_DESTINATION share/sproto
)

install(FILES
    \"\${CMAKE_CURRENT_BINARY_DIR}/sproto-config.cmake\"
    DESTINATION share/sproto
)
")

# Create config template
file(WRITE "${SOURCE_PATH}/sproto-config.cmake.in" "
@PACKAGE_INIT@

include(\"\${CMAKE_CURRENT_LIST_DIR}/sproto-targets.cmake\")

check_required_components(sproto)
")

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
)

vcpkg_cmake_build()

vcpkg_cmake_install()

# Remove debug includes
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

# Remove empty lib directories as suggested by the warning
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/lib" "${CURRENT_PACKAGES_DIR}/lib")

# Handle copyright
file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)

vcpkg_cmake_config_fixup(CONFIG_PATH share/sproto)