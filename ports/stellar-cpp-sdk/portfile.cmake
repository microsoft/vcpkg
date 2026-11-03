vcpkg_from_github(
  OUT_SOURCE_PATH SOURCE_PATH
  REPO Olvisgil/stellar-cpp-sdk
  REF "v${VERSION}"
  SHA512 fe054c70fe297d5251f2cbcaa8a30633ba0b9a47c81c892c052dabf85c2c4840c1fbcf6d88a2f4f469bb98997a8d90f2a7440ae0ba8faaae60bfd0a7579473be
  HEAD_REF main
)

# The SDK builds STATIC libraries only: generated XDR symbols carry no export
# annotations and the build hides visibility by default.
vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_cmake_configure(
  SOURCE_PATH "${SOURCE_PATH}"
  OPTIONS
    -DSTELLAR_SDK_BUILD_TESTS=OFF
    -DSTELLAR_SDK_BUILD_TOOLS=OFF
    -DSTELLAR_SDK_BUILD_EXAMPLES=OFF
    -DSTELLAR_SDK_BUILD_FUZZERS=OFF
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(PACKAGE_NAME StellarSdk CONFIG_PATH lib/cmake/StellarSdk)
vcpkg_copy_pdbs()
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE" "${SOURCE_PATH}/NOTICE")
