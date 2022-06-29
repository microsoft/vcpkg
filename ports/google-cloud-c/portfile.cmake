vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO            "offscale/${PORT}"
    REF             9a362f7916a69c2806baaa7a3ba0c83477db7f96
    SHA512          db16777e12e47044a0da5d98461802f6ed0ef5d82c3844eea68793615384b29e2f5d23afca84db18ead17d764f0fba7d9fdc89d4be4cc36063e167b694a5282a
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
