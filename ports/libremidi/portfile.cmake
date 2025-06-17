vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO jcelerier/libremidi
    REF "v${VERSION}"
    SHA512 8a9608eaabcf23866ee69e7f7999f8017f7f032003c33003b62b7891672d2a9d2609422bb1f509b3bd5647f628ed0707b14d188a8c44b27bd2ea54199ede8f32
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
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/${PORT})

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE.md")
