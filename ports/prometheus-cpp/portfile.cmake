vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO jupp0r/prometheus-cpp
    REF "v${VERSION}"
    SHA512 8c15492054189b736e502258c30aaaae0fac3c9ea61907260e6e3cd29fe4077451f9e49fd580508aa6e21691209545d9cf87011be5b046fa097a53a133167553
    HEAD_REF master
)

vcpkg_check_features(
    OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        compression ENABLE_COMPRESSION
        pull ENABLE_PULL
        push ENABLE_PUSH
        tests ENABLE_TESTING
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DUSE_THIRDPARTY_LIBRARIES=OFF # use vcpkg packages
        -DGENERATE_PKGCONFIG=OFF
        ${FEATURE_OPTIONS}
)

vcpkg_cmake_install()

vcpkg_copy_pdbs()

vcpkg_cmake_config_fixup(CONFIG_PATH "lib/cmake/prometheus-cpp")

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

# Handle copyright
configure_file("${SOURCE_PATH}/LICENSE" "${CURRENT_PACKAGES_DIR}/share/${PORT}/copyright" COPYONLY)
