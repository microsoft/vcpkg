vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO            SamuelMarks/curl-simple-https
    REF             fc79ebd6213e8339bac79b571c9784260c95a1e7
    SHA512          b52ba4f389d1c289b2a3611826cfb76c2f0b22ac3eec2d012019e4b46a5a7052df487cfe55cbf367abe850d962d9fc2c9e19db344a764432252c467cc862ec79
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
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include"
                    "${CURRENT_PACKAGES_DIR}/debug/share")
