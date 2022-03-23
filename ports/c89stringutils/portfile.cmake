vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO            offscale/c89stringutils
    REF             ceb4a109fd186ca560938bc009cb2db6dbbbfadb
    SHA512          85655cd691d6f3bd629c57275f396776c4e21e43023de34e94cd3e782ca8580032055202e227eabc655373ba358ebc6ce8f6d724f7e5a5d2332631b4af6a44b7
    HEAD_REF        master
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        "-DBUILD_TESTING=OFF"
)
vcpkg_cmake_install()
file(INSTALL "${SOURCE_PATH}/cmake/LICENSE.txt"
     DESTINATION "${CURRENT_PACKAGES_DIR}/share/c89stringutils"
     RENAME copyright)
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug")
