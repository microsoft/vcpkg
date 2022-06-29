vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO            "offscale/${PORT}"
    REF             0f76ad0d59abc6a6b56d768447bfd49af50cd3cf
    SHA512          122987c4477d5f02d9a882cec487fa5e8bf9d7872a8046e50157987b323b40808ca6152085d46f71a9ee2a4c4a898f5cd6beebed9554318bae90ca81a099c864
    HEAD_REF        master
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        "-DBUILD_TESTING=OFF"
        "-DBUILD_REAL_API_TESTING=OFF"
        "-DBUILD_PARSE_EMIT_TESTS=OFF"
)
vcpkg_cmake_install()
file(INSTALL "${SOURCE_PATH}/cmake/License.txt"
     DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}"
     RENAME copyright)
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share"
                    "${CURRENT_PACKAGES_DIR}/debug/include")
