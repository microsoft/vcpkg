vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO            offscale/c89randomstr
    REF             9d577c4343913a330ef32b93ed12b8942808bbbc
    SHA512          7adfac8000d9057b9ca230f794bff82e1628864140e08d393e3faff890848606fff72c3dd2b296a20bf3003ed035e9e4273a0599764f515b7a6ac7091e9d2949
    HEAD_REF        master
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        "-DBUILD_TESTING=OFF"
)
vcpkg_cmake_install()
file(INSTALL "${SOURCE_PATH}/COPYING"
     DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}"
     RENAME copyright)
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug")
