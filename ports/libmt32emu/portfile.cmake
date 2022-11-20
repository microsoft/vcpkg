vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO munt/munt
    REF 08aba2f0018f4e7c2af855c268a97b8b84f8dc06  #vlibmt32emu_2_7_0
    SHA512 ef277767c6c18b1aa341b2e2cdac04c27bc19ef0aa2f1e0a4125c92128f64d5938eab53cf1d6bf2f9abaa5a59d14873e91e1518878165af48ac6b93c3e208aa5
    HEAD_REF master
)

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "dynamic" BUILD_SHARED)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}/mt32emu"
    OPTIONS
        -Dlibmt32emu_SHARED:BOOL=${BUILD_SHARED}
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(PACKAGE_NAME MT32Emu CONFIG_PATH lib/cmake/MT32Emu)

vcpkg_fixup_pkgconfig()

vcpkg_copy_pdbs()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/share/doc")


file(INSTALL "${SOURCE_PATH}/mt32emu/COPYING.txt" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
