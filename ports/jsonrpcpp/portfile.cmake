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

# Remove bundled json.hpp from install command and delete the file
vcpkg_replace_string(
    "${SOURCE_PATH}/CMakeLists.txt"
    "install(FILES include/jsonrpcpp.hpp include/json.hpp"
    "install(FILES include/jsonrpcpp.hpp"
)
file(REMOVE "${SOURCE_PATH}/include/json.hpp")

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DBUILD_EXAMPLE=OFF
        -DBUILD_TESTS=OFF
)

vcpkg_cmake_install()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug")

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
