vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO            septag/dmon
    REF             a670919356a13a0a96c31fb647e57f4a9ff341b5
    SHA512          a80b55fa05f8911ae85150ccf193bd6fa9265a025813d671ec5f3a47bb9e450052c074ee740bf07346b269d6283d3a64b74ecdb8274540ebcfa5395a2e7d4b29
    HEAD_REF        master
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        "-DBUILD_TESTS=OFF"
)
vcpkg_cmake_install()
file(INSTALL "${SOURCE_PATH}/LICENSE"
     DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}"
     RENAME copyright)
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug")
