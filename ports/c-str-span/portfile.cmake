vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO            SamuelMarks/c-str-span
    REF             48c049b8d38fd09f2870646faef0603a89657706
    SHA512          a561dc63696dc470f128cf95f8cbb50e85f5378d99ddfda9291c0cb5585225dabb2c615188474dd116ef7fa56a01e7622d63c657b6c77a88a62e96138475223a
    HEAD_REF        master
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        "-DBUILD_TESTING=OFF"
)
vcpkg_cmake_install()
file(INSTALL "${SOURCE_PATH}/LICENSE-MIT"
     DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}"
     RENAME copyright)
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include"
                    "${CURRENT_PACKAGES_DIR}/debug/share")
