vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO jupp0r/prometheus-cpp
    REF 4ea303fa66e4c26dc4df67045fa0edf09c2f3077 # v1.0.0
    SHA512 f97f380182cb7d8576f444e263159d5cc4572d71020b14a2d599041a6a4e5e2cb677a80c637b5a2bca55d4f0e570e87c2863d5dd48e317e9a912cca5a192e81a
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
