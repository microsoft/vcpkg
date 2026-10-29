vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Taywee/args
    REF "${VERSION}"
    SHA512 970620f088e9eb67ff70c8eaa7c3e1cc4e84135a30db010a6e3d139f8294e8a17c885e6e7700bbfbc1f55036a47d829d3c48f3756ae999bf0ddcae065fcc00bb
    HEAD_REF master
)

set(VCPKG_BUILD_TYPE release) # header-only port

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DARGS_BUILD_UNITTESTS=OFF
        -DARGS_BUILD_EXAMPLE=OFF
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/${PORT})
vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/lib")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
