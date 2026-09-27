vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO uber/h3
    REF "v${VERSION}"
    SHA512 8b74989632e2f23ecd26098d1accf6289ab0aac025ed695eafc0919e450090f935990518d26cb5b2f01df180e60f1bf3896607bc39771808b63ffc87a18921e4
    HEAD_REF master
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DBUILD_BENCHMARKS=OFF
        -DBUILD_FUZZERS=OFF
        -DBUILD_FILTERS=OFF
        -DBUILD_GENERATORS=OFF
        -DBUILD_TESTING=OFF

        -DENABLE_DOCS=OFF
        -DENABLE_FORMAT=OFF
        -DENABLE_LINTING=OFF
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(CONFIG_PATH "lib/cmake/${PORT}")
vcpkg_fixup_pkgconfig()

vcpkg_copy_pdbs()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/bin" "${CURRENT_PACKAGES_DIR}/debug/bin" "${CURRENT_PACKAGES_DIR}/debug/include")

file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
