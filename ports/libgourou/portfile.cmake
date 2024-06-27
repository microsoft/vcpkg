vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO            SamuelMarks/${PORT}
    REF             bf9d0f82db99e76ed27ff80ca9646ceb5c5f4823
    SHA512          29bd105da1658eb820f95d8b4449443f8327ef20e42283517bc7bc12698dba86051450e11988826020e36231e5c8bfeb2efed9d7dbe9d10f4f08a514de709922
    HEAD_REF        cmake
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
)
vcpkg_cmake_install()
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/cmake/License.txt")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include"
                    "${CURRENT_PACKAGES_DIR}/debug/share")
