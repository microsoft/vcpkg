vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO ccsb-scripps/AutoDock-Vina
    REF v${VERSION}
    SHA512 d36908e5833d22bcbc4dae353ef32b905d6eb46511302f7583a291398bfadff5e75fc99ce7b380860578b2257e5c32434cc75b1ca51fafb4b5f12d9477a878e9
    HEAD_REF develop
    PATCHES
        fix-compatibility-with-boost-1.83.patch
        fix-compatibility-with-boost-1.85.patch
)

file(COPY "${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt" DESTINATION "${SOURCE_PATH}")

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup()

vcpkg_copy_pdbs()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

file(
    INSTALL "${SOURCE_PATH}/LICENSE"
    DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}"
    RENAME copyright
)
