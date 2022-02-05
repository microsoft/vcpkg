vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO            SamuelMarks/curl-simple-https
    REF             61cc5c43284d5d37296b93ecb8403bd1f05d55ca
    SHA512          dace996b848cf4d14253f6b7a3130bcd1fbd31b6d2d2a85e83947c6c644d4ac45a8d7fbf05491658e449b25965c99f68fbbcb1b89d792e0fb2b1e7b727287f1c
    HEAD_REF        master
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        "-DBUILD_CLI=OFF"
)
vcpkg_cmake_install()
file(INSTALL "${SOURCE_PATH}/cmake/License.txt"
     DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}"
     RENAME copyright)
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug")
