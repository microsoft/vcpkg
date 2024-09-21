vcpkg_from_github(
  OUT_SOURCE_PATH SOURCE_PATH
  REPO David-Haim/concurrencpp
  REF "v.${VERSION}"
  SHA512 b87a6bd0593d6a7d35f911a0a9835e1afe416aa25d06e4d448789617c94ec2faeb5df07d68d5ccc7e986009f09016f90ef57016b1aabe567996d3ad9816add4c
  HEAD_REF master
  PATCHES
    fix-include-path.patch
    add-include-string.patch
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
)

vcpkg_cmake_install()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_cmake_config_fixup(CONFIG_PATH "lib/cmake/concurrencpp-${VERSION}")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE.txt")
