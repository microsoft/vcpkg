vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO jupp0r/prometheus-cpp
    REF "v${VERSION}"
    SHA512 e397f25c7a62d410d19be5e926cfb38175c89755e4ff9d67f06b905036daa82b0dfbe21fcc69438fc1c1e5d04f120ef7ff983ca9411ab198a3911992efb00093
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
