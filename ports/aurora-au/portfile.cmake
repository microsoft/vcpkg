set(VCPKG_BUILD_TYPE release)  # header-only

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO aurora-opensource/au
    REF "${VERSION}"
    SHA512 4be3d1c4f595852d57352572d58137b98c5a51074926cf06fe65420c277f72dc2f03d61bb25e87ceb3e4050181145557766e77af19c6aee7b0d1fe7ec3a8029b
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
