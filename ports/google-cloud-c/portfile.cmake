vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO            "offscale/${PORT}"
    REF             be86523be428c0241e54dddbb4a1f4d1ef516173
    SHA512          7cdc6c4d0812d1a23e0a934684d279ae6a79a3c03e7276037bec1ec985a60c4938a34e510b555f5ee2bc4a71675b68ca292e60ed21f5bf437799eaff7d2c2a79
    HEAD_REF        master
)

vcpkg_cmake_configure(SOURCE_PATH "${SOURCE_PATH}")
vcpkg_cmake_install()
file(INSTALL "${SOURCE_PATH}/cmake/License.txt"
     DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}"
     RENAME copyright)
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share"
                    "${CURRENT_PACKAGES_DIR}/debug/include")
