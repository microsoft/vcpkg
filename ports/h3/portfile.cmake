vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO uber/h3
    REF v${VERSION}
    SHA512 7b9a18ff1714465d8c980607cf62b4e73e2be199f02f24d85004760b48d523686cb9e7f8891d821545b4ef8a2d547c6eb9880e419d0799a4f549323b7f8e9f94
    HEAD_REF master
)

vcpkg_cmake_configure(
    SOURCE_PATH ${SOURCE_PATH}
    OPTIONS
        -DBUILD_BENCHMARKS=OFF
        -DBUILD_FUZZERS=OFF
        -DBUILD_FILTERS=OFF
        -DBUILD_GENERATORS=OFF
        -DBUILD_TESTING=OFF
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/${PORT})

vcpkg_copy_pdbs()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/bin" "${CURRENT_PACKAGES_DIR}/debug/bin" "${CURRENT_PACKAGES_DIR}/debug/include")

file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
