vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO graeme-hill/crossguid
    REF ca1bf4b810e2d188d04cb6286f957008ee1b7681 #2021-10-22
    SHA512 f0a80d8e99b10473bcfdfde3d1c5fd7b766959819f0d1c0595ac84ce46db9007a5fbfde9a55aca60530c46cb7f8ef4c7e472c6191559ded92f868589c141ccaf
    HEAD_REF master
    PATCHES
        warnings.patch
        missing-include-cstdint.patch
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DCROSSGUID_TESTS:BOOL=OFF
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(CONFIG_PATH share/crossguid/cmake)

vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include" "${CURRENT_PACKAGES_DIR}/debug/share")

# Handle copyright
file(RENAME "${CURRENT_PACKAGES_DIR}/share/${PORT}/LICENSE" "${CURRENT_PACKAGES_DIR}/share/${PORT}/copyright")
