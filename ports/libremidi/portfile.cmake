vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO jcelerier/libremidi
    REF "v${VERSION}"

    SHA512 7b73d5e1a565e9f85ac28fba041c66a151537a9205b4f3605fa70e18d5e651fa0562329853c7e08bf8e620f9d83d08d167b746d30c39bffcd325fbd6338d0538 
    HEAD_REF master
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DLIBREMIDI_NO_ALSA=ON
        -DLIBREMIDI_NO_BOOST=ON
        -DLIBREMIDI_NO_JACK=ON
)
vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/libremidi PACKAGE_NAME libremidi)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE.md")
