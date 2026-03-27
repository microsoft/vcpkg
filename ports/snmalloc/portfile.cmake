# Without static-shim: INTERFACE only — Release and Debug are identical.
# With static-shim: compiled code is produced — both variants are needed.
if(NOT "static-shim" IN_LIST FEATURES)
    set(VCPKG_BUILD_TYPE release)
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO microsoft/snmalloc
    REF "${VERSION}"
    SHA512 ef15272dc488f87e59d273b7db780f2bdfdea9d539c9d7a56987dffd62cd4e0daaf46d6138a3aa1f7c77ab14a71c47d66d1250248e1e87060c5bb8e1ede709ba
    HEAD_REF main
)

# NOTE: The CI overlay port (see .github/workflows/main.yml, vcpkg-integration)
# uses sed to extract from this line onwards to build a portfile that points at
# the local checkout. If you reorder code above this line, update the sed
# pattern there.
vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        "static-shim" SNMALLOC_STATIC_LIBRARY
    INVERTED_FEATURES
        "static-shim" SNMALLOC_HEADER_ONLY_LIBRARY
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DSNMALLOC_BUILD_TESTING=OFF
        ${FEATURE_OPTIONS}
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(
    PACKAGE_NAME snmalloc
    CONFIG_PATH share/snmalloc
)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage"
    DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
