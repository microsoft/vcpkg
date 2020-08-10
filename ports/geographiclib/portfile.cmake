vcpkg_from_sourceforge (
    OUT_SOURCE_PATH SOURCE_PATH
    REPO geographiclib
    REF distrib
    FILENAME "GeographicLib-1.50.1.tar.gz"
    SHA512 1db874f30957a0edb8a1df3eee6db73cc993629e3005fe912e317a4ba908e7d7580ce483bb0054c4b46370b8edaec989609fb7e4eb6ba00c80182db43db436f1
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

file (GLOB TOOL_LIST LIST_DIRECTORIES false
  ${CURRENT_PACKAGES_DIR}/tools/*)
if (TOOL_LIST)
  file (INSTALL ${TOOL_LIST}
    DESTINATION "${CURRENT_PACKAGES_DIR}/tools/${PORT}")
  vcpkg_copy_tool_dependencies (${CURRENT_PACKAGES_DIR}/tools/${PORT})
  file (REMOVE ${TOOL_LIST})
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
