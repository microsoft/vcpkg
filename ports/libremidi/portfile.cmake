vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO jcelerier/libremidi
    REF "v${VERSION}"
    SHA512 f2de03b7188220acc7579499e83b8e64ecb47af3448f446c2e6cda2bef84fe29a9cae86d38f548eb7f75d87b2f18de3987184cba189e17167190d3415d9e63e5
    HEAD_REF master
)

vcpkg_list(SET options)
if(VCPKG_TARGET_IS_LINUX)
    vcpkg_list(APPEND options -DLIBREMIDI_NO_ALSA=OFF)
else()
    vcpkg_list(APPEND options -DLIBREMIDI_NO_ALSA=ON)
endif()

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        ${options}
        -DLIBREMIDI_NO_BOOST=ON
        -DLIBREMIDI_NO_JACK=ON
        -DLIBREMIDI_NO_PIPEWIRE=ON
)
vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH "lib/cmake/${PORT}")

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE.md")
