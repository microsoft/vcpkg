vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

if("hexl" IN_LIST FEATURES)
    vcpkg_fail_port_install(ON_ARCH "x86" "arm" "arm64")
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO microsoft/APSI
    REF 2eba8a245872755a76282c4f1b14aefd67b1a199
    SHA512 fd21e41b9a3241dc3454fadb54feb7843d9d4d4563da26d0f4a29b67ea22ead24ff6d89029050f5c54225cb95cb181f346f381b98873d3c55173444c0650d581
    HEAD_REF main
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        log4cplus APSI_USE_LOG4CPLUS
        zeromq APSI_USE_ZMQ
)

vcpkg_cmake_configure(
    SOURCE_PATH ${SOURCE_PATH}
    DISABLE_PARALLEL_CONFIGURE
    OPTIONS
        "-DAPSI_BUILD_TESTS=OFF"
        "-DAPSI_BUILD_CLI=OFF"
        ${FEATURE_OPTIONS}
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(PACKAGE_NAME "APSI" CONFIG_PATH "lib/cmake/APSI-0.2")

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME "copyright")

vcpkg_copy_pdbs()
