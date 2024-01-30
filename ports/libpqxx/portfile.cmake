vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO jtv/libpqxx
    REF "${VERSION}"
    SHA512 ce37fdfce2671d97e422ae3339fb5650065111b0635a7293200c56a8755a7dc7de80806816863c606c46b6049e4cb490d24dfb97446ea0014b55907554862fed
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

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/COPYING")

vcpkg_fixup_pkgconfig()
