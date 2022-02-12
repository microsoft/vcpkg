vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO            "offscale/${PORT}"
    REF             d573aaf57b38c6a5cfdc16e9a4c0f54c83c2f7c5
    SHA512          90350bdc9c738a4e167247138136c2f07ae20cadb8be3050196135c59e11387673acc8e2f15622be6d37c937b3ed2456967b6e9ce1632d8be484a9dd2691d72b
    HEAD_REF        master
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
)
vcpkg_cmake_install()
file(INSTALL "${SOURCE_PATH}/cmake/LICENSE.txt"
     DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}"
     RENAME copyright)
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug")
