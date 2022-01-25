vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO jtv/libpqxx
    REF 221ddc8be329bafb376a3d83b9cd257fd52fc7b7 # 7.6.0
    SHA512 32a673bbae2f26fbc41bdcba007d9a5ded29680cb49ba434d1913cd5007bc1c1443bf38c88d9c5a6abe0a3ee519c0f691464c8d2b144cd3f16652447d644e400
    HEAD_REF master
    PATCHES
        fix_build_with_vs2017.patch
        fix_build_with_apple_clang_13.patch
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
