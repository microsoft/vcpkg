vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO            "offscale/${PORT}"
    REF             b0d682e670c7c33b23f6e37c45aec423bbf599ad
    SHA512          0b4a3e61813edbbc2bc02fef8cd4b594ae9882bb6eac1169d894be4bfe71521ade3ef97a920778e782fcd7dfe3c31ac7d646ba728855a46395592d530ce03a88
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
