vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO jcelerier/libremidi
    REF "v${VERSION}"
    SHA512 7eac753eedb7cb420881182516b8d9af710dde3d70c9decf0650dbd5d08a0b1c798b79454aa1d18db07fb6761d6d05d91312e546c57d67cfb815dce731709aab
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
        -DLIBREMIDI_NO_ANDROID=ON
        -DLIBREMIDI_NO_WINMIDI=ON
)
vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH "lib/cmake/${PORT}")

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE.md")
