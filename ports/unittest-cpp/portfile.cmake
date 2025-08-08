vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO unittest-cpp/unittest-cpp
    REF v2.0.0
    SHA512 39318f4ed31534c116679a3257bf1438a6c4b3bef1894dfd40aea934950c6c8197af6a7f61539b8e9ddc67327c9388d7e8a6f8a3e0e966ad26c07554e2429cab
    HEAD_REF master
    PATCHES
        fix-include-path.patch
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DUTPP_INCLUDE_TESTS_IN_BUILD=OFF
        -DUTPP_AMPLIFY_WARNINGS=OFF
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/UnitTest++ PACKAGE_NAME unittest++)

# Handle copyright
file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)

# Remove duplicate includes
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_fixup_pkgconfig()
