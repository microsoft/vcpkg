vcpkg_from_github(
  OUT_SOURCE_PATH SOURCE_PATH
  REPO Olvisgil/stellar-cpp-sdk
  REF "v${VERSION}"
  SHA512 10f92a4edc833d188c4cb2cfa593f110109e7a2140575eb4444340789dac205384465339fe370e8ba8fc209f3cee0953a47eeadddb8092ae0221f4b986e8ce1b
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
