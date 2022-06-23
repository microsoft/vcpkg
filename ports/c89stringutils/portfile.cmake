vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO            offscale/c89stringutils
    REF             0c57e435d594cf956ba7b6ff86148c6376eec5be
    SHA512          e68b5218c2689105ea4a0e6a852e45795e3a33feb8eb20183ddb1485d0fc028fee027c63d6dc71e931f5b56199db812a7ccd5db6f6992750fd975b5df342a6bf
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
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
