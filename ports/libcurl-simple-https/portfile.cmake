vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO            SamuelMarks/curl-simple-https
    REF             d459a09ea8cfae798dc6792fb929a1e722916ec0
    SHA512          e29efdb714d58b1b34a7e29c09750344c060403527cadcb4d01117adf3f82de70f8db8f2a32224efba4fb3544d2f33ee25f1323e18222adddc3d9eb1ffc610a6
    HEAD_REF        master
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        "-DBUILD_CLI=OFF"
)
vcpkg_cmake_install()
file(INSTALL "${SOURCE_PATH}/License.txt"
     DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}"
     RENAME copyright)
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug")
