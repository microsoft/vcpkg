vcpkg_from_sourceforge (
    OUT_SOURCE_PATH SOURCE_PATH
    REPO geographiclib
    REF distrib
    FILENAME "GeographicLib-1.52.tar.gz"
    SHA512 98a4d33764db4a4755851a7db639fd9e055dcf4f1f949258e112fce2e198076b5896fcae2c1ea36b37fe1000d28eec326636a730e70f25bc19a1610423ba6859
    PATCHES cxx-library-only.patch
)

vcpkg_check_features (
  OUT_FEATURE_OPTIONS FEATURE_OPTIONS
  INVERTED_FEATURES
    "tools" SKIP_TOOLS
)

if (VCPKG_LIBRARY_LINKAGE STREQUAL dynamic)
  set (LIB_TYPE "SHARED")
else ()
  set (LIB_TYPE "STATIC")
endif ()

vcpkg_configure_cmake (
    SOURCE_PATH ${SOURCE_PATH}
    OPTIONS
        "-DGEOGRAPHICLIB_LIB_TYPE=${LIB_TYPE}"
        ${FEATURE_OPTIONS}
    PREFER_NINJA # Disable this option if project cannot be built with Ninja
)

vcpkg_install_cmake ()
vcpkg_fixup_cmake_targets (CONFIG_PATH share/geographiclib)
vcpkg_copy_pdbs ()

if (tools IN_LIST FEATURES)
  vcpkg_copy_tool_dependencies (${CURRENT_PACKAGES_DIR}/tools/${PORT})
endif ()

file (REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)
file (REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file (REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/tools)
file (INSTALL ${SOURCE_PATH}/LICENSE.txt
  DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT}
  RENAME copyright)

# Install usage
configure_file (${CMAKE_CURRENT_LIST_DIR}/usage
  ${CURRENT_PACKAGES_DIR}/share/${PORT}/usage @ONLY)

vcpkg_fixup_pkgconfig()
