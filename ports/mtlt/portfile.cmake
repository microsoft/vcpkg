set(VCPKG_BUILD_TYPE release) # Header-only library

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO tonitaga/MTLT
    REF 8e30e6636b06ad008082e22f37e0d79873142e1b
    SHA512 2addaa4f84037a14431b20734fe5ca1ea11c4d9d1a0ddf82a16b9efaacbbac3873038bd16f93ba94288559585ae76d12884166931c91a214a3e3ed0cecea6b3b
    HEAD_REF main
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(PACKAGE_NAME "mtlt" CONFIG_PATH "lib/cmake/mtlt")
vcpkg_fixup_pkgconfig()
vcpkg_copy_pdbs()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/lib")

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
