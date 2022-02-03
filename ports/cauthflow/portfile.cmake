vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO            offscale/cauthflow
    REF             a5ad7823b2c0f9372118962f3bca8f963fbc4d52
    SHA512          4998deef77d06be4eb7534a227d10cc7ec77bdad53059c0672c6d9450d965c21f609416f341222f2a22deaaedf0905b38066dbe1da8fbf8ad83bdf29fb64e48e
    HEAD_REF        master
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
)
vcpkg_cmake_install()
file(INSTALL "${SOURCE_PATH}/cmake/LICENSE.txt"
     DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}"
     RENAME copyright)
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug")
