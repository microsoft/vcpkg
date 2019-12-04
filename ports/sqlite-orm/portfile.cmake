include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO fnc12/sqlite_orm
    REF v1.4
    SHA512 b9ff600af568c2de982467cec9ef057e7cb687dc9123e84596590d2e4e51bf41db02a2e6386ef264b832530d4d05c2c18455c8c7d85498b15a9d76601ec81e75
    HEAD_REF master
)

file(COPY ${SOURCE_PATH}/include/sqlite_orm DESTINATION ${CURRENT_PACKAGES_DIR}/include/)

file(INSTALL
    ${SOURCE_PATH}/LICENSE
    DESTINATION ${CURRENT_PACKAGES_DIR}/share/sqlite-orm RENAME copyright)
