vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO            SamuelMarks/curl-simple-https
    REF             d0908bccce80d978bab9bd43ead2acf18b5bfb94
    SHA512          88005a64adf86f51eb977166b67f5b209dc3454567febdb0d725a4f7f2d18487d7942d1f15d83a949d6d6a65689f5bbed018b6dafaec93bc553428a14f95ec63
    HEAD_REF        master
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        "-DBUILD_CLI=OFF"
)
vcpkg_cmake_install()
file(INSTALL "${SOURCE_PATH}/cmake/License.txt"
     DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}"
     RENAME copyright)
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug")
