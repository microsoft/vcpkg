set(VCPKG_BUILD_TYPE release)  # header-only

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO aurora-opensource/au
    REF "${VERSION}"
    SHA512 675487ecaba256caa085f309a266e822356cdb286a242a2103d008cacc908409e053b296ad6b4c750657ed17a2b2712f6171fac41c74c2fbfb9db034479abaf1
    HEAD_REF main
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DAU_EXCLUDE_GTEST_DEPENDENCY=1
    )

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(
    CONFIG_PATH lib/cmake/Au
)

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE.txt")

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/lib")  # Remove empty directory
file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
