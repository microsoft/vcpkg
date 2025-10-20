# dllexport is not supported.
if(VCPKG_TARGET_IS_WINDOWS)
    vcpkg_check_linkage(ONLY_STATIC_LIBRARY)
endif()

vcpkg_from_github(
  OUT_SOURCE_PATH SOURCE_PATH
  REPO obgm/libcoap
  REF v4.3.5
  SHA512 21332f4988c83cc3e26a70db6f2c3028e75fabc7990238d3c13666c5725674231799e147427b0fa827cf6c9e4d9f03d5176129f69425e2439ade13ea82267c05
  HEAD_REF main)

vcpkg_check_features(
  OUT_FEATURE_OPTIONS FEATURE_OPTIONS
  FEATURES
      examples ENABLE_EXAMPLES
      dtls     ENABLE_DTLS
)

vcpkg_cmake_configure(
  SOURCE_PATH ${SOURCE_PATH}
  # There is a configure_file with output in source file.
  DISABLE_PARALLEL_CONFIGURE
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

# A false condition hardcodes CMAKE_BINARY_DIR:
# CMakeLists.txt:811
#          $<$<AND:$<BOOL:${COAP_WITH_LIBTINYDTLS}>,$<BOOL:${USE_VENDORED_TINYDTLS}>>:${CMAKE_BINARY_DIR}/include/tinydtls>
set(VCPKG_POLICY_SKIP_ABSOLUTE_PATHS_CHECK enabled)
