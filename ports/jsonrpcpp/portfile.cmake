vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO badaix/jsonrpcpp
    REF "v${VERSION}"
    SHA512 d6c1ff8113f1b8581c258acdc7f59a3669e43636b06d73db1c4396da4a7797dc9b1d7e3a9f81039cc06c2970806b9b5a565cb2d9c8f0041866067dfcded93fff
    HEAD_REF master
    PATCHES
        fix-include-path.patch
        add-cmake-targets.patch
)

# Remove bundled json.hpp
file(REMOVE "${SOURCE_PATH}/include/json.hpp")

file(COPY "${CMAKE_CURRENT_LIST_DIR}/unofficial-jsonrpcpp-config.cmake.in" DESTINATION "${SOURCE_PATH}")

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DBUILD_EXAMPLE=OFF
        -DBUILD_TESTS=OFF
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(PACKAGE_NAME unofficial-jsonrpcpp CONFIG_PATH share/unofficial-jsonrpcpp)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug")

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
