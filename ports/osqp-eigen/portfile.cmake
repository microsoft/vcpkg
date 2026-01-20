vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO "gbionics/osqp-eigen"
    REF "v${VERSION}"
    SHA512 89f3e83dbaf925f7690c11a553c402c3cadda2d33c3f94f25096b11708f9f8753a3f4ef64d632c553399e95467e887fc37972be94fcad74c63de989ad3a1dde4
    PATCHES osqp-eigen.patch
)

vcpkg_cmake_configure(
  SOURCE_PATH "${SOURCE_PATH}"
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(
    PACKAGE_NAME  "OsqpEigen"
    CONFIG_PATH "lib/cmake/OsqpEigen"
)

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
