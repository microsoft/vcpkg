include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO fnc12/sqlite_orm
    REF v1.3
    SHA512 43adcd28bdca5d0165ca0313c5ff90e048144e4841541704f49e443deaf0d8e027655a3bb88677f3f3c62c5764fdda8b1e472d74e68f3a32cad052f3b4ed63a7
    HEAD_REF master
)

file(COPY ${SOURCE_PATH}/include/sqlite_orm DESTINATION ${CURRENT_PACKAGES_DIR}/include/)

file(INSTALL
    ${SOURCE_PATH}/LICENSE
    DESTINATION ${CURRENT_PACKAGES_DIR}/share/sqlite-orm RENAME copyright)
