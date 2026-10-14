vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO an-tao/trantor
    REF "v${VERSION}"
    SHA512 2c690c3613f8d3cbc0834881d2f731c3d935e5b9002ddcbca4a298a6fc7c2cb81d72f25516b5dc8b367208fb4e3ae1544af9f1046eade5acc52f144490f7b615
    HEAD_REF master
    PATCHES
        000-fix-deps.patch
        001-disable-werror.patch
        002-export-certificate.patch
)

set(feature_options)
if("spdlog" IN_LIST FEATURES)
    list(APPEND feature_options "-DUSE_SPDLOG=ON")
else()
    list(APPEND feature_options "-DUSE_SPDLOG=OFF")
endif()

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        ${feature_options}
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/Trantor)

vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/License")

vcpkg_copy_pdbs()
