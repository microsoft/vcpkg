vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO buck-yeh/bux-mariadb-client
    REF aa7a543ed98081f357f1f27e2d77b66b81d727d6 # v1.0.3
    SHA512 35877ec1f17f43c4215c2662613ec00fc4e8a851087809aadcf4770ef1691b645a6804bfd12124af39db9338e28e9c1ed87fe03bf38e1675651a9c325df23b24
    HEAD_REF main
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
)

vcpkg_cmake_install()
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
