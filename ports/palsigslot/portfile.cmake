vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO palacaze/sigslot
    REF "v${VERSION}"
    SHA512 ed8614d9c2e418259b1bce6d0a528b54939700876969c5e8dfcfc466c167690180cb18324602f83d521c79dcba2565e5317647416b70cf8773860ab956d9b62f
    HEAD_REF master
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
      -DSIGSLOT_COMPILE_EXAMPLES=OFF
      -DSIGSLOT_COMPILE_TESTS=OFF
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(PACKAGE_NAME PalSigslot CONFIG_PATH lib/cmake/PalSigslot)

file(REMOVE_RECURSE
    "${CURRENT_PACKAGES_DIR}/debug"
    "${CURRENT_PACKAGES_DIR}/lib"
)

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
