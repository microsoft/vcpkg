vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO            "offscale/${PORT}"
    REF             57463e58af91bf0aaad419dec795d8024c3c1931
    SHA512          fc8593e6c8f508d27f24a62cdb70244bfbaf63fe5a7141c7ff39baa3b9cc41bda97baad68eff9ad8167117243b6cb370a4504295bc116ea8786e0b0189f91075
    HEAD_REF        master
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DBUILD_TESTING=OFF
)
vcpkg_cmake_install()
file(INSTALL "${SOURCE_PATH}/cmake/License.txt"
     DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}"
     RENAME copyright)
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share"
                    "${CURRENT_PACKAGES_DIR}/debug/include")
