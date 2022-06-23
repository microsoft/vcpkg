vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO            "offscale/${PORT}"
    REF             20050ebe62436054096616142aafeaedf5006660
    SHA512          3417399785022f149a63e0458031023c35554b1b211f4973af8d63896619f87e2c50196e08a12f40f8bc6d54544b0c125af7cf7656bcbb4386fce66ff3ae2519
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
