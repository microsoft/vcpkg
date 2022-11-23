vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO            "offscale/${PORT}"
    REF             a8ff2be9686171e486cdf886b0e81892a37ddcae
    SHA512          fcba80057b7ebe074d8b6af820b25619141d06d995eee7fa7b58637335b4419ff8de69462339c65e5bc6feebf3d180619e25ef61c57122f347d4c03ce6e8e34f
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
