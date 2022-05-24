vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO            offscale/c89stringutils
    REF             ad6d0bf9fd81486e09c2ad755ef7124543d863b0
    SHA512          c97875cd205c473ac2dcf993f7a4c66172e2890d142414e49d2a159e7989d3d53c80f5ef3fa940e1d4b66327bee18a318564e1bfc04d82e19ec4a7605f0e8590
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
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug")
