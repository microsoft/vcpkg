vcpkg_from_sourceforge (
  OUT_SOURCE_PATH SOURCE_PATH
  REPO geographiclib
  REF distrib-C++
  FILENAME "GeographicLib-2.0.tar.gz"
  SHA512 7cf67174a64082372cdd249a64460e9f61c582aaf3d2a31e4e69d811f265e078ba62f945e9f1f44be6c58de4c20d0359dd46e0fd262ffac229df0ba2c6adc848
  )

vcpkg_check_features (
  OUT_FEATURE_OPTIONS FEATURE_OPTIONS
  FEATURES "tools" TOOLS
)

set (COMMON_OPTIONS
  "-DBUILD_DOCUMENTATION=OFF"
  "-DCMAKEDIR=share/${PORT}"
  "-DPKGDIR="
  "-DDOCDIR="
  "-DEXAMPLEDIR="
  "-DMANDIR="
  "-DSBINDIR=")

if (TOOLS)
  set (TOOL_OPTION "-DBINDIR=tools/${PORT}")
else ()
  set (TOOL_OPTION "-DBINDIR=")
endif ()

vcpkg_cmake_configure (
    SOURCE_PATH ${SOURCE_PATH}
    OPTIONS ${LIB_OPTION} ${COMMON_OPTIONS} ${TOOL_OPTION}
    PREFER_NINJA # Disable this option if project cannot be built with Ninja
)

vcpkg_cmake_install ()
vcpkg_cmake_config_fixup ()
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

vcpkg_fixup_pkgconfig ()
