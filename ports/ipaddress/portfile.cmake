vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO vladimirshaleev/ipaddress
    REF 73c10065b659bddcaffa8ffa1576d1317b0c6c3c # v1.0.1
    SHA512 4ec7b20f953dfa32c561acdcae141bc2d05195473b68f98df37631b3f2a6d46fb75ede78990078d1cfa7490f922443525e2ad95a2dfca8a248688a09b537a800
    HEAD_REF main
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    INVERTED_FEATURES
        "exceptions"   IPADDRESS_NO_EXCEPTIONS
        "ipv6-scope"   IPADDRESS_NO_IPV6_SCOPE
        "overload-std" IPADDRESS_NO_OVERLOAD_STD
)

vcpkg_cmake_configure(
    SOURCE_PATH ${SOURCE_PATH}
    OPTIONS
        ${FEATURE_OPTIONS}
        -DIPADDRESS_BUILD_DOC=OFF
        -DIPADDRESS_BUILD_TESTS=OFF
        -DIPADDRESS_BUILD_BENCHMARK=OFF
        -DIPADDRESS_BUILD_PACKAGES=OFF
        -DIPADDRESS_ENABLE_CLANG_TIDY=OFF
)
vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH share/cmake/${PORT})
vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
