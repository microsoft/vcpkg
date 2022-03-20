vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO            "offscale/${PORT}"
    REF             61ee52a2e6cff4ddcfd12ae416fa203bc1c0d16a
    SHA512          8826184182d31e59bf6a295a273e8f63b1f384485ff53b4ae6095f1bf10f4e45d4a5c1f393f76de05fa3fc4ef060d29307b6b049d83df0b521114d8b883e6f12
    HEAD_REF        master
)

vcpkg_cmake_configure(SOURCE_PATH "${SOURCE_PATH}")
vcpkg_cmake_install()
file(INSTALL "${SOURCE_PATH}/cmake/License.txt"
     DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}"
     RENAME copyright)
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share"
                    "${CURRENT_PACKAGES_DIR}/debug/include")
