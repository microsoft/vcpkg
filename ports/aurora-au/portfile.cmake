set(VCPKG_BUILD_TYPE release)  # header-only

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO aurora-opensource/au
    REF "${VERSION}"
    SHA512 85b90924f82a123000ecc3c9a1f44f31d6f1a7f3664968abc27f4fbdc6712b7bc9a8a30428b9422529fed7fe269a13c57e0dad8483658530dcbfa0c6b15daa6c
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
