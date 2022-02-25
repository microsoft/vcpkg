vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO            "offscale/${PORT}"
    REF             27f8ab78e6f7c3a10b4ab145a138115c5e0e22a1
    SHA512          5224d9476ec28c3f98adac0d79e87ba3c2fdfc606954388d547ca3d87b84df207981b509276c296b84852887022df84c42b583a40c14299dbfb97b4d31d1d006
    HEAD_REF        master
)

vcpkg_cmake_configure(SOURCE_PATH "${SOURCE_PATH}")
vcpkg_cmake_install()
file(INSTALL "${SOURCE_PATH}/cmake/License.txt"
     DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}"
     RENAME copyright)
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include"
                    "${CURRENT_PACKAGES_DIR}/debug/share")
