set(VCPKG_POLICY_MISMATCHED_NUMBER_OF_BINARIES enabled)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO oneapi-src/oneTBB
    REF v2021.5.0
    SHA512 0e7b71022e397a6d7abb0cea106847935ae79a1e12a6976f8d038668c6eca8775ed971202c5bd518f7e517092b67af805cc5feb04b5c3a40e9fbf972cc703a46
)

    vcpkg_configure_cmake(
        SOURCE_PATH ${SOURCE_PATH}
        PREFER_NINJA
        OPTIONS
            -DTBB_TEST=OFF
    )

    vcpkg_install_cmake()
    vcpkg_cmake_config_fixup(
        CONFIG_PATH lib/cmake/TBB
    )

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

file(COPY ${CMAKE_CURRENT_LIST_DIR}/usage DESTINATION ${CURRENT_PACKAGES_DIR}/share/tbb)
# Handle copyright
file(INSTALL ${SOURCE_PATH}/LICENSE.txt DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
