if(VCPKG_TARGET_IS_WINDOWS)
    vcpkg_check_linkage(ONLY_STATIC_LIBRARY)
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO configcat/cpp-sdk
    REF "v${VERSION}"
    SHA512 c36c136a16cc7206e1516546d075535a1cb1756649a51fc632f3ac1b0a31e3f23f41f8aac0989aee725bac9949a722db6cbc75111276b43403607e1fc25ce866
    HEAD_REF master
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    INVERTED_FEATURES
        network CONFIGCAT_USE_EXTERNAL_NETWORK_ADAPTER
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DCONFIGCAT_BUILD_TESTS=OFF
        ${FEATURE_OPTIONS}
)
vcpkg_cmake_install()

vcpkg_cmake_config_fixup(CONFIG_PATH "share/cmake/configcat")

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
