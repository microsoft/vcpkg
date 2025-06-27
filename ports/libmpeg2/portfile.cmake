vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

# There is archived version of releases available at https://github.com/janisozaur/libmpeg2
vcpkg_from_git(
    OUT_SOURCE_PATH SOURCE_PATH
    URL https://code.videolan.org/videolan/libmpeg2.git
    REF 946bf4b518aacc224f845e73708f99e394744499  # Use a pinned commit hash
    PATCHES
        0001-Add-naive-MSVC-support-to-sources.patch
)

file(COPY "${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt" DESTINATION "${SOURCE_PATH}")

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
  FEATURES
    tools   TOOLS
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS ${FEATURE_OPTIONS}
)

vcpkg_cmake_install()

# # Handle copyright
file(INSTALL "${SOURCE_PATH}/COPYING" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_copy_pdbs()
