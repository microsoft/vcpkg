vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO AOMediaCodec/libavif
    REF "v${VERSION}"
    SHA512 cbf31827884058acc54d3b1fa0f2059f022691609a76e0f913981d5b8c1be60f52069a25b61c888c09e963161d1f4c9bf692c0716ab0ee067a4ccaa4e36d9ce1
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
if("svt" IN_LIST FEATURES)
    list(APPEND FEATURE_OPTIONS "-DAVIF_CODEC_SVT=SYSTEM")
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
