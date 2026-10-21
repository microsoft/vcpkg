vcpkg_download_distfile(ARCHIVE
    URLS "https://github.com/krpc/krpc/releases/download/v${VERSION}/krpc-cnano-${VERSION}.zip"
    FILENAME "krpc-cnano-${VERSION}.zip"
    SHA512 acd10d610b09fdfb788710e8d0cf13078de16439b90538833cd4e41a29aa51fdb75767ae6ca70148a42843d7f99ac1183894af54fb07a9682762597217a4ae4b
)

vcpkg_extract_source_archive(SOURCE_PATH
    ARCHIVE "${ARCHIVE}"
    SOURCE_BASE "krpc-cnano-${VERSION}"
)

# Which transport the library talks to the server over. Each is a feature rather than the default
# because a program using the library is built for the same transport it is, so asking for one is
# what tells vcpkg to hand out a library that speaks it.
vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        tcp         KRPC_COMMUNICATION_TCP
        localsocket KRPC_COMMUNICATION_LOCALSOCKET
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DKRPC_FETCH_NANOPB=OFF
        -DKRPC_REGENERATE_PROTO=OFF
        ${FEATURE_OPTIONS}
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/krpc_cnano PACKAGE_NAME krpc_cnano)
vcpkg_copy_pdbs()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
vcpkg_install_copyright(FILE_LIST
    "${SOURCE_PATH}/COPYING.LESSER"
    "${CURRENT_INSTALLED_DIR}/share/nanopb/copyright"
)
