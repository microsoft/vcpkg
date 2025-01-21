vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO AOMediaCodec/libavif
    REF "v${VERSION}"
    SHA512 ba72b8d02b098f361643a073361fccafd22eaac14e46dd06378d5e7acd9853538c5d166473e1de0b020de62dac25be83e42bd57ba51f675d11e2ddf155fbfa21
    HEAD_REF master
    PATCHES
        dependencies.diff
        disable-source-utf8.patch
)
file(REMOVE_RECURSE "${SOURCE_PATH}/third_party")

set(FEATURE_OPTIONS "")
if("aom" IN_LIST FEATURES)
    list(APPEND FEATURE_OPTIONS "-DAVIF_CODEC_AOM=SYSTEM")
endif()
if("dav1d" IN_LIST FEATURES)
    list(APPEND FEATURE_OPTIONS "-DAVIF_CODEC_DAV1D=SYSTEM")
endif()

vcpkg_find_acquire_program(PKGCONFIG)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        ${FEATURE_OPTIONS}
        "-DPKG_CONFIG_EXECUTABLE=${PKGCONFIG}"
)
vcpkg_cmake_install()
vcpkg_copy_pdbs()
vcpkg_fixup_pkgconfig()
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/${PORT})

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include"
                    "${CURRENT_PACKAGES_DIR}/debug/share")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
