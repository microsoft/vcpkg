vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO hoshimoe/NekoSchema
    REF v1.1.6
    SHA512 26667e1b0de688c288665c6aa098403311227ddf635b98e9984cecdd67ab43429d620214a9048a3d3d7c8268ac4217463328cc1d03aa8a31a00078b29624c70c
    HEAD_REF main
)

set(VCPKG_BUILD_TYPE release) # header-only port

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DNEKO_SCHEMA_BUILD_TESTS=OFF
        -DNEKO_SCHEMA_AUTO_FETCH_DEPS=OFF
        -DNEKO_SCHEMA_ENABLE_MODULE=OFF
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/NekoSchema PACKAGE_NAME nekoschema)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/lib")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
