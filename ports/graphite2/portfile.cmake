vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO silnrsi/graphite
    REF "${VERSION}"
    SHA512 eb1f1772bfc4457d9aa68e99236b8cd6a01c7d93e97ac97f4d93d26db363bc785d71bb780dfdbced28e6e10d3e24eb281e0ff2b678bf57eca722a61f08020dfb
    HEAD_REF master
    PATCHES
        disable_features.patch
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DBUILD_TESTING=OFF
)

vcpkg_cmake_install()
vcpkg_copy_pdbs()
vcpkg_cmake_config_fixup()
vcpkg_fixup_pkgconfig()

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/include/graphite2/Types.h" "defined GRAPHITE2_STATIC" "1")
endif()

file(REMOVE_RECURSE
    "${CURRENT_PACKAGES_DIR}/debug/include"
    "${CURRENT_PACKAGES_DIR}/debug/share"
    "${CURRENT_PACKAGES_DIR}/lib/libgraphite2.la"
    "${CURRENT_PACKAGES_DIR}/debug/lib/libgraphite2.la"
)

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/COPYING" "${SOURCE_PATH}/LICENSE")

