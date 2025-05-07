vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO AOMediaCodec/libavif
    REF "v${VERSION}"
    SHA512 13eb641a17c59d70c465995dca6f921e7a40867053b8d8f0792a68aeaf9dde029daacc77df2049ebb8235ae3b1a35651f5b38a37914bdafe3b8884c64822b1e8
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
