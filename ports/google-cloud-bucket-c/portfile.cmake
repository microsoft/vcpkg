vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO            "offscale/${PORT}"
    REF             68fadc96c0c0d35ac3c0d0eb9a2e7177bcb75328
    SHA512          001dbdd8ccf4fc5babc46363f4b4f72b001c427ced5faf33b6c92d60a145200a9dbfc026d94fdb1abd63249f02ad270de520a915ff603ba78dbc71b52dd203d4
    HEAD_REF        master
)

vcpkg_cmake_configure(SOURCE_PATH "${SOURCE_PATH}")
vcpkg_cmake_install()
file(INSTALL "${SOURCE_PATH}/cmake/License.txt"
     DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}"
     RENAME copyright)
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include"
                    "${CURRENT_PACKAGES_DIR}/debug/share")
