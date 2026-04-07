# dllexport is not supported.
if(VCPKG_TARGET_IS_WINDOWS)
  vcpkg_check_linkage(ONLY_STATIC_LIBRARY)
endif()

vcpkg_download_distfile(DLLEXPORT_PATCH
    URLS https://github.com/obgm/libcoap/commit/0bd03b658ed2d75fdb7cb8f6add201b39b428298.patch?full_index=1
    FILENAME obgm-remove-self-configure-file-0bd03b658ed2d75fdb7cb8f6add201b39b428298.patch
    SHA512 6c120dc278a5d73d0b9bd2f66468c822ccde80513262201119cdceb9ed6fdf2f84d473926373f18ef69d709d4e95212e484079072a52d5c65d09e4ccb82368e5
)

vcpkg_from_github(
  OUT_SOURCE_PATH SOURCE_PATH
  REPO obgm/libcoap
  REF "v${VERSION}"
  SHA512 9f46f8293e0cfd2c6c3300693ffc8de1c2217f1cad4cd05e59ea6b6995f42d5d31ea02d4fadddd9b071f711cf651b711c2a26e4b826244fc80e014ed66f368a7
  HEAD_REF main
  PATCHES
      "${DLLEXPORT_PATCH}"
      remove-hardcoded-tinydtls-path.patch)

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
