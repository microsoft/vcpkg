vcpkg_from_github(
  OUT_SOURCE_PATH SOURCE_PATH
  REPO blend2d/blend2d
  REF 68ef9107503c0c5675daf310ea11e835b6a6f31f # commited on 2024-07-07
  SHA512 c525fffa2259bfc68dfd626a4d607526d4a87139b9202f51f7fdd617c6114c683b7c72b146674a3479f7ab8f942eccf1b35d2dfed2b0936dabbafb392e084038
  HEAD_REF master
)

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "static" BLEND2D_STATIC)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
  INVERTED_FEATURES
    jit        BLEND2D_NO_JIT
    tls        BLEND2D_NO_TLS
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        "-DBLEND2D_STATIC=${BLEND2D_STATIC}"
        "-DBLEND2D_NO_FUTEX=OFF"
        "-DBLEND2D_EXTERNAL_ASMJIT=ON"
        ${FEATURE_OPTIONS}
)

vcpkg_cmake_install()
vcpkg_copy_pdbs()

vcpkg_cmake_config_fixup(CONFIG_PATH "lib/cmake/${PORT}")

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
if(BLEND2D_STATIC)
  file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/bin" "${CURRENT_PACKAGES_DIR}/debug/bin")
endif()

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE.md")

if(BLEND2D_STATIC)
  file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage_static.txt" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME usage)
else()
  file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
endif()
