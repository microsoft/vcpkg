vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO            offscale/cauthflow
    REF             7a6315eb279246035b866335bd39b543083dd9df
    SHA512          d98c7bc8d9b28b1bceaaf69597017b7a1787e6edadd73a4add0ecb1614e21f4ccf0f085d978afc68a05e014f049f8c1e952228a1995f3599e9ba679c88b6af47
    HEAD_REF        master
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
)
vcpkg_cmake_install()
file(INSTALL "${SOURCE_PATH}/cmake/LICENSE.txt"
     DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}"
     RENAME copyright)
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug")
