vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO oneapi-src/level-zero
    REF "v${VERSION}"
    SHA512 ada1978dc80d0e1441fe41faf5cd2ac0bd6ab8dbb4f30745f1686c5c42b425dc47bd7991c6754cb50a52dadb7211245358544157be909a3c968b9e94011c8a2f
    HEAD_REF master
    PATCHES spdlog_include.patch
)

vcpkg_list(SET options)
if (VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    vcpkg_list(APPEND options "-DBUILD_STATIC=1")
endif()

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DSYSTEM_SPDLOG=ON
        ${options}
)

vcpkg_cmake_install()
vcpkg_fixup_pkgconfig()
vcpkg_copy_pdbs()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")

