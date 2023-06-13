vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO endingly/games101-cgl
    REF v0.1.0
    SHA512  195131a0621bbe4e0c88e1237d85521576c423e1484ec15f3778d97eaa1c06bd3824dfcd54b8926540896ea141ca70035bb395fa042a0c1fb5455e67ad48afad
    HEAD_REF main
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
)

vcpkg_cmake_install()
vcpkg_copy_pdbs()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/license")