vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO            offscale/c89stringutils
    REF             3953f216fc9f46ed704fedd465d096e744f00ea4
    SHA512          1a8a65e59d12b623f563eff3a86e21f6cdce1528542be1fc979865f21f9e9c14c3fafada60994ede505ccf263825561a4d2c5b252ef7374b087743d859bafb6b
    HEAD_REF        master
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        "-DBUILD_TESTING=OFF"
)
vcpkg_cmake_install()
file(INSTALL "${SOURCE_PATH}/cmake/LICENSE.txt"
     DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}"
     RENAME copyright)
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share"
                    "${CURRENT_PACKAGES_DIR}/debug/include")
