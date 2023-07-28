vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO lammertb/libfins
    REF b686d55a21be4c1dcc31e23f794141f27ee7c714
    SHA512  73686b1cb32638574c22a18ddcb7ee9320bb34489ee58ad2e971e3382a1a3a48f16996698b2f23b2e46f9cb1d06a3683971a70d3c5bb6d779edff5673b79b9d6
    HEAD_REF master
    PATCHES
        "add_cmake_support.patch"
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
)

vcpkg_cmake_install()
vcpkg_copy_pdbs()
vcpkg_cmake_config_fixup()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
# file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")



