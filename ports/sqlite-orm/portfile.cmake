include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO fnc12/sqlite_orm
    REF v1.2
    SHA512 b2c87bb643337b5f59d96f8a22e2c6ae040116f51bd86b75e1085d0c06618af131a36d312040d0cf49533269fa840f4e575812b017c7b80b121e1f27825723b5
    HEAD_REF master
)

file(COPY ${SOURCE_PATH}/include/sqlite_orm DESTINATION ${CURRENT_PACKAGES_DIR}/include/)

file(INSTALL
    ${SOURCE_PATH}/LICENSE
    DESTINATION ${CURRENT_PACKAGES_DIR}/share/sqlite-orm RENAME copyright)
