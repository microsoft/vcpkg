vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO            offscale/cauthflow
    REF             b30c271b25adb3af66a65a0444d469ae97aaddb5
    SHA512          8e90f40d79e740680afe0e141f73e7faa6c42a5241c8b86b44af1fa65d70d682f7d834882c3d56c90b093fd4a73b4125451a0bf6f5cab3d4a2bc5e4983672aea
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
