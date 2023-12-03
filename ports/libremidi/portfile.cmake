vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO jcelerier/libremidi
    REF "v${VERSION}"
    SHA512 ed07f8553155fe7c643033e67e12f1eaf64c11240bb387d9dc2c7e5c54af95cf5b9a78472b2281c7f2f4ef27a8f06ae981705f1fa2321f1322842becc1406247
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
