# dllexport is not supported.
if(VCPKG_TARGET_IS_WINDOWS)
  vcpkg_check_linkage(ONLY_STATIC_LIBRARY)
endif()

vcpkg_from_github(
  OUT_SOURCE_PATH SOURCE_PATH
  REPO obgm/libcoap
  REF "v${VERSION}"
  SHA512 b8fc435412cd1909bc9ba5683cfa138a3ea08a76fecab78739ceedc7bb903d15d50d4362f702f7380fd047e5b6df3c76dfb75dd30bb20670a62205e6bc85021d
  HEAD_REF main
  PATCHES
      obgm-remove-self-configure-file.patch # https://github.com/obgm/libcoap/pull/1736
      remove-hardcoded-tinydtls-path.patch
)

vcpkg_check_features(
  OUT_FEATURE_OPTIONS FEATURE_OPTIONS
  FEATURES
      examples ENABLE_EXAMPLES
      dtls     ENABLE_DTLS
)

vcpkg_cmake_configure(
  SOURCE_PATH "${SOURCE_PATH}"
  OPTIONS
      ${FEATURE_OPTIONS}
      -DENABLE_DOCS=OFF
      -DDTLS_BACKEND=openssl)

vcpkg_cmake_install()
vcpkg_copy_pdbs()
vcpkg_cmake_config_fixup(CONFIG_PATH "lib/cmake/libcoap")

if("examples" IN_LIST FEATURES)
  vcpkg_copy_tools(
      TOOL_NAMES coap-client coap-rd coap-server
      AUTO_CLEAN
  )
  # Same condition in licoap/CMakeLists.txt
  if(NOT VCPKG_TARGET_IS_WINDOWS AND NOT VCPKG_TARGET_IS_MINGW)
    vcpkg_copy_tools(
        TOOL_NAMES etsi_iot_01 tiny oscore-interop-server
        AUTO_CLEAN
    )
  endif()
endif()

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
