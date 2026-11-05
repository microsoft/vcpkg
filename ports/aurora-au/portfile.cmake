set(VCPKG_BUILD_TYPE release)  # header-only

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO aurora-opensource/au
    REF "${VERSION}"
    SHA512 d5f22dd74277a2fd38479d58e6725c36d03ca82e227fed5c6491b44415d07ec5efdfb327a4c7f72a55fdba277d6f836171c2edc787a5b86706660ca4b90260df
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
