vcpkg_from_github(
  OUT_SOURCE_PATH SOURCE_PATH
  REPO upa-url/upa
  REF "v${VERSION}"
  SHA512 3517a03a8f974b0e853983701a1c91f390128fe327af172f4e6aab3db4218cdd8385efed58920688a373e54eafeb128003ece130a0ea059a35dad9c81c9df4f6
  HEAD_REF main
)

vcpkg_cmake_configure(
  SOURCE_PATH "${SOURCE_PATH}"
  OPTIONS
    -DUPA_BUILD_TESTS=OFF
)

vcpkg_cmake_install()
vcpkg_copy_pdbs()
vcpkg_cmake_config_fixup(PACKAGE_NAME "upa" CONFIG_PATH "lib/cmake/upa")
vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

# This file includes "srell/srell.hpp" which is not currently a dependency of this port.
file(REMOVE "${CURRENT_PACKAGES_DIR}/include/upa/regex_engine_srell.h")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
