vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO            offscale/c89stringutils
    REF             43bd8d948b198dbc5ec9571f06ecb6fc40f1609b
    SHA512          a5506ac5c233aadef8d703a0dfafe4152965699f3922671e74b9ae9635b5e73b1e9e6d305a0f6ce3d725dc4dadc64fae677b5349544c7055f5130d47c20bac05
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
