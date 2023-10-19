vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO jcelerier/libremidi
    REF "v${VERSION}"

    SHA512 de7092c70af6fc0a23c8e6018fbd9f380632ac9dec8794171726fda9a6e7ba45479a8e8317919ba7a8a0267524bab8d5430782a54bc50a914658cf277e18145b
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
)
vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/libremidi PACKAGE_NAME libremidi)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE.md")
