vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO            "offscale/${PORT}"
    REF             8434a2b1dd4c39b5effc215a85d3fba93326f269
    SHA512          697e3ea338f0af72662a87fdd6e6f3c8fda9533d255ed1b9433cd808015cfbe9570e123163b6be1f1bd31f7e84163db5b40e32f4828934333e4b47df6a96ac5f
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
