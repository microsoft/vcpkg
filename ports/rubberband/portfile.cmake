vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
      cli CLI
)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO breakfastquay/rubberband
    REF v2.0.2
    SHA512 56e33f3a6f5755242e46f9cb224e372bea7a367756f08d3322c8951a40b3907f1a2957775de6f2584a093e6adf82ca91015119650d5a624afe39086a47843ddc
    HEAD_REF default
)

vcpkg_configure_meson(SOURCE_PATH "${SOURCE_PATH}")
vcpkg_install_meson()

vcpkg_fixup_pkgconfig()
vcpkg_copy_pdbs()

if(CLI)
  vcpkg_copy_tools(TOOL_NAMES rubberband)
endif()

file(INSTALL "${SOURCE_PATH}/COPYING" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/bin" "${CURRENT_PACKAGES_DIR}/debug/bin")
