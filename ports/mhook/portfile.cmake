vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO apriorit/mhook
    REF 2.5.1
    SHA512 914f198417b1e30301a42463af5cfbf9269dc64bcf1be87d3d6d2943fd72b3536f48eb4bfb25a51dd0bbe0f8f099777b2d49c9d58cb2e2eeb517d998917ae976
    HEAD_REF master
    PATCHES fix-windows-packing-mismatch.patch
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
)

vcpkg_cmake_install()
vcpkg_copy_pdbs()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(INSTALL "${SOURCE_PATH}/COPYING" DESTINATION "${CURRENT_PACKAGES_DIR}/share/mhook" RENAME copyright)

