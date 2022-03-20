vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO            "offscale/${PORT}"
    REF             5dd38428055f2856cce90444c051fe1cc899a85a
    SHA512          51bbcb5887e869a43e8c62ab00e2c03ebfe28133c162d21df431818339c0bd2a7ffbe3c4c58b6a0395202dcdcea5103ccb766f9a6c500839e5b6ff62cce71d24
    HEAD_REF        master
)

vcpkg_cmake_configure(SOURCE_PATH "${SOURCE_PATH}")
vcpkg_cmake_install()
file(INSTALL "${SOURCE_PATH}/cmake/License.txt"
     DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}"
     RENAME copyright)
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share"
                    "${CURRENT_PACKAGES_DIR}/debug/include")
