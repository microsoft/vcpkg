vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO gracicot/kangaru
    REF v4.3.1
    SHA512 5c1c6081b266089ad4ef310f4782505db5c514adce87091dd8164a6da71fc7ef72c0992c32e9ec3c991aa7a2ca43f1d96f2f524c7198bf899876af214fea28f3
    HEAD_REF master
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        hashtypeid KANGARU_HASH_TYPE_ID
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DKANGARU_EXPORT=OFF
        -DKANGARU_TEST=OFF
        -DKANGARU_REVERSE_DESTRUCTION=ON
        ${FEATURE_OPTIONS}
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/kangaru)

file(REMOVE_RECURSE
    "${CURRENT_PACKAGES_DIR}/lib"
    "${CURRENT_PACKAGES_DIR}/debug"
)

# Put the license file where vcpkg expects it
file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
