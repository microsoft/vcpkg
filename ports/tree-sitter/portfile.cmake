vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO            "SamuelMarks/${PORT}"
    REF             982cdce15b88e41b1f6938cc0e103b0e7a3cc830
    SHA512          f427f9ac2e7e7722819d7e4fd36d111b7fd745dac9d934a2fec46c87a98e45708143dd93460dcf12d120b168a0bb24ef6d7e1e06e5666e7028a9f825c5d52f63
    HEAD_REF        cmake
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        "-DBUILD_TESTING=OFF"
)
vcpkg_cmake_install()
file(INSTALL "${SOURCE_PATH}/LICENSE"
     DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}"
     RENAME copyright)
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share"
                    "${CURRENT_PACKAGES_DIR}/debug/include")
