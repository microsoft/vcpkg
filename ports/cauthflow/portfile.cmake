vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO            offscale/cauthflow
    REF             029e05aa0dbb1efcff8034200a1327118927f793
    SHA512          70109508c00db5a69c0466d209d2d6c2d6aedd2b2c3ad7abbe8f8af0b45cd9b610f0dcf0248a565d4d27f3a4b47496eff39ca2db368775fffcebd8959dfdf21f
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
