vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

# There is archived version of releases available at https://github.com/janisozaur/libmpeg2
vcpkg_download_distfile(ARCHIVE
    URLS "https://download.videolan.org/contrib/libmpeg2/libmpeg2-0.5.1.tar.gz"
    FILENAME "libmpeg2-0.5.1.tar.gz"
    SHA512 3648a2b3d7e2056d5adb328acd2fb983a1fa9a05ccb6f9388cc686c819445421811f42e8439418a0491a13080977f074a0d8bf8fa6bc101ff245ddea65a46fbc
)

vcpkg_extract_source_archive(
    SOURCE_PATH
    ARCHIVE "${ARCHIVE}"
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
