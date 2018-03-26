include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO fnc12/sqlite_orm
    REF v1.1
    SHA512 ebd3c956660b90b1ea64420374db009c68cbab1edd3694d15e953c968190c066e084934327dcf674bcea31e23b14d32c54af7e9ba54f7c6036c3e7cb7cdc6c8d
    HEAD_REF master
)

file(COPY ${SOURCE_PATH}/include/sqlite_orm DESTINATION ${CURRENT_PACKAGES_DIR}/include/)

file(INSTALL
    ${SOURCE_PATH}/LICENSE
    DESTINATION ${CURRENT_PACKAGES_DIR}/share/sqlite-orm RENAME copyright)
