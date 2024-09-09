vcpkg_download_distfile(ARCHIVE
    URLS "https://dlcdn.apache.org/httpd/httpd-2.4.62.tar.gz"
    FILENAME "httpd-2.4.62.tar.gz"
    SHA512 daf66daf1012c6df6266e13a743cabf6ac8b6552b83d3a2db89eb491813ba5acd28e4149e5abe5a03f10677f23b74ae6a319e3c69dd6d223ca8269751960818a
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        pdb     INSTALL_PDB
        manual  INSTALL_MANUAL
)

vcpkg_extract_source_archive_ex(
    OUT_SOURCE_PATH SOURCE_PATH
    ARCHIVE "${ARCHIVE}"
)

vcpkg_cmake_configure(
    SOURCE_PATH
        "${SOURCE_PATH}"
    OPTIONS
        "-DAPR_INCLUDE_DIR=${CURRENT_INSTALLED_DIR}/include"
        "-DAPR_LIBRARIES=${CURRENT_INSTALLED_DIR}/lib/libapr-1.lib;${CURRENT_INSTALLED_DIR}/lib/libaprutil-1.lib"
        "-DPCRE_LIBRARIES=${CURRENT_INSTALLED_DIR}/lib/pcre2-8.lib"
        "-DPCRE_INCLUDE_DIR=${CURRENT_INSTALLED_DIR}/include"
        "-DPCRE_CFLAGS=-DHAVE_PCRE2"
        "${FEATURE_OPTIONS}"
    MAYBE_UNUSED_VARIABLES
        PKG_CONFIG_EXECUTABLE
)

set(VCPKG_POLICY_EMPTY_INCLUDE_FOLDER enabled)

vcpkg_cmake_install()

file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
