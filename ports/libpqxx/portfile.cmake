vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO jtv/libpqxx
    REF 90768b07f7feb55a9bd70cfaacb5543bfd074022 # 7.7.3
    SHA512 cbb21b148135d9426acd8006bfab872997bae65cfaa7af414083a8d219f099edcc83de7bde5e36016c1f8333f1e4d03fc401a4e741dfd0881afda3e1a20009ff 
    HEAD_REF master
    PATCHES
        fix_build_with_vs2017.patch
)

file(COPY "${CMAKE_CURRENT_LIST_DIR}/config-public-compiler.h.in" DESTINATION "${SOURCE_PATH}")
file(COPY "${CMAKE_CURRENT_LIST_DIR}/config-internal-compiler.h.in" DESTINATION "${SOURCE_PATH}")

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DSKIP_BUILD_TEST=ON
)

vcpkg_cmake_install()
vcpkg_copy_pdbs()

vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/libpqxx)
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include" "${CURRENT_PACKAGES_DIR}/debug/share")

file(INSTALL "${SOURCE_PATH}/COPYING" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)

vcpkg_fixup_pkgconfig()
