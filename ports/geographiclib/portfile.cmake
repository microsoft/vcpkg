vcpkg_from_sourceforge (
    OUT_SOURCE_PATH SOURCE_PATH
    REPO geographiclib
    REF distrib
    FILENAME "GeographicLib-1.51.tar.gz"
    SHA512 34487a09fa94a34d24179cfe9fd2e5fdda28675966703ca137cbfe6cc88760c2fbde55f76c464de060b58bfe0a516e22c0f59318cf85ae7cc01c5c6a73dd6ead
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

if (tools IN_LIST FEATURES)
  vcpkg_fail_port_install (
    MESSAGE "Cannot build GeographicLib tools for UWP"
    ON_TARGET uwp
  )
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
