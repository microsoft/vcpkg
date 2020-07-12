vcpkg_from_sourceforge (
  OUT_SOURCE_PATH SOURCE_PATH
  REPO geographiclib
  REF distrib
  FILENAME "GeographicLib-1.50.1.tar.gz"
  SHA512 1db874f30957a0edb8a1df3eee6db73cc993629e3005fe912e317a4ba908e7d7580ce483bb0054c4b46370b8edaec989609fb7e4eb6ba00c80182db43db436f1
  PATCHES cxx-library-only.patch
)

if (VCPKG_TARGET_TRIPLET MATCHES ".*-uwp")
  set (SKIP_TOOLS_OPTION "-DSKIP_TOOLS=ON")
else ()
  set (SKIP_TOOLS_OPTION "-DSKIP_TOOLS=OFF")
endif ()

if (VCPKG_LIBRARY_LINKAGE STREQUAL dynamic)
  set (LIB_TYPE "-DGEOGRAPHICLIB_LIB_TYPE=SHARED")
else ()
  set (LIB_TYPE "-DGEOGRAPHICLIB_LIB_TYPE=STATIC")
endif ()

vcpkg_configure_cmake (
  SOURCE_PATH ${SOURCE_PATH}
  OPTIONS ${LIB_TYPE} ${SKIP_TOOLS_OPTION}
  PREFER_NINJA # Disable this option if project cannot be built with Ninja
  )

vcpkg_install_cmake ()
vcpkg_fixup_cmake_targets (CONFIG_PATH share/geographiclib)
vcpkg_copy_pdbs ()
vcpkg_copy_tool_dependencies(${CURRENT_PACKAGES_DIR}/tools/${PORT})

file (REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)
file (REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file (INSTALL ${SOURCE_PATH}/LICENSE.txt
  DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT}
  RENAME copyright)

# Install usage
configure_file (${CMAKE_CURRENT_LIST_DIR}/usage
  ${CURRENT_PACKAGES_DIR}/share/${PORT}/usage @ONLY)

# Post-build test for cmake libraries
vcpkg_test_cmake(PACKAGE_NAME GeographicLib)
