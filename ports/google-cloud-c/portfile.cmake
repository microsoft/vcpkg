vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO            "offscale/${PORT}"
    REF             758698107c4118f1d6c20a8dff91e57fbc2f73bd
    SHA512          80bef49cd4e3be459c31ba2804e379e419865a48e9d966b34c59f4a8a73e3c33b19b02fcbd21c9a680aa7f8078c36508ed27e8d6884336d42b58160a3b594723
    HEAD_REF        master
)

vcpkg_cmake_configure(SOURCE_PATH "${SOURCE_PATH}")
vcpkg_cmake_install()
file(INSTALL "${SOURCE_PATH}/cmake/License.txt"
     DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}"
     RENAME copyright)
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share"
                    "${CURRENT_PACKAGES_DIR}/debug/include")
