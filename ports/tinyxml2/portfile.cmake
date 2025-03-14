vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO leethomason/tinyxml2
    REF "${VERSION}"
    SHA512 acdd42c7431de65272fdcb2cdf64beb44efc97deffed45f9933453883182238a60071bec5dda2f87d166dd8455e8cd3118af6937ddd7c6abacafda2a060f6cc6
    HEAD_REF master
    PATCHES
        0001-fix-do-not-force-export-the-symbols-when-building-st.patch
        0002-fix-check-for-TINYXML2_EXPORT-on-non-windows.patch
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -Dtinyxml2_BUILD_TESTING=OFF
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/tinyxml2)
vcpkg_fixup_pkgconfig()

vcpkg_copy_pdbs()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

file(INSTALL "${SOURCE_PATH}/LICENSE.txt" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
