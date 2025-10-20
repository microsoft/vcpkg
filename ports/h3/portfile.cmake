vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO uber/h3
    REF v${VERSION}
    SHA512 6ed93c5e69adbba9804282b5814f1617d4c930b677df4735e4d4cf10fcba813f61b6be3a125d191d375e52e3e22af7c244efb007f27ca487b34eae9e24fb6c7b
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
