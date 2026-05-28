vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO badaix/jsonrpcpp
    REF "v${VERSION}"
    SHA512 d6c1ff8113f1b8581c258acdc7f59a3669e43636b06d73db1c4396da4a7797dc9b1d7e3a9f81039cc06c2970806b9b5a565cb2d9c8f0041866067dfcded93fff
    HEAD_REF master
)

# Fix include path to use vcpkg's nlohmann-json
vcpkg_replace_string(
    "${SOURCE_PATH}/include/jsonrpcpp.hpp"
    [[#include <json.hpp>]]
    [[#include <nlohmann/json.hpp>]]
)

# Remove bundled json.hpp
file(REMOVE "${SOURCE_PATH}/include/json.hpp")

# Patch CMakeLists.txt: add CMake targets and remove bundled json.hpp from install
vcpkg_replace_string(
    "${SOURCE_PATH}/CMakeLists.txt"
    [[include_directories(
	"include"
)

install(FILES include/jsonrpcpp.hpp include/json.hpp
    DESTINATION "${CMAKE_INSTALL_INCLUDEDIR}/jsonrpcpp")]]
    [[find_package(nlohmann_json CONFIG REQUIRED)

add_library(${PROJECT_NAME} INTERFACE)
target_include_directories(${PROJECT_NAME} INTERFACE
    $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/include>
    $<INSTALL_INTERFACE:${CMAKE_INSTALL_INCLUDEDIR}>
)
target_link_libraries(${PROJECT_NAME} INTERFACE nlohmann_json::nlohmann_json)

install(TARGETS ${PROJECT_NAME}
    EXPORT jsonrpcpp-targets
    INCLUDES DESTINATION "${CMAKE_INSTALL_INCLUDEDIR}"
)
install(EXPORT jsonrpcpp-targets
    NAMESPACE jsonrpcpp::
    FILE jsonrpcpp-config.cmake
    DESTINATION share/jsonrpcpp
)

install(FILES include/jsonrpcpp.hpp
    DESTINATION "${CMAKE_INSTALL_INCLUDEDIR}/jsonrpcpp")]]
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DBUILD_EXAMPLE=OFF
        -DBUILD_TESTS=OFF
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(PACKAGE_NAME jsonrpcpp)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug")

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
