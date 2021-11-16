vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

if("hexl" IN_LIST FEATURES)
    vcpkg_fail_port_install(ON_ARCH "x86" "arm" "arm64")
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO microsoft/APSI
    REF 4e412e6c89a2729a09aa2a998b212dec0fa9a0fc
    SHA512 8cabe842884a90bd3de5156af964f68efe77c55c1ff773ce3a64a0c4e3380868dd5ee79f4db2033278eba2c7cf5561c225b1625313a7ac89f068218d5cb9f40c
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

vcpkg_cmake_config_fixup(PACKAGE_NAME "APSI" CONFIG_PATH "lib/cmake/APSI-0.5")

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME "copyright")

vcpkg_copy_pdbs()
