include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO fnc12/sqlite_orm
    REF 1.3
    SHA512 9d61d65a8987f875aacca9dd262d5b1e4dca273aef938fc5c292469b215b244edc63fb6428199e16ed6d254f752e1a9574306b15ebb099a4bf4f744510975da3
    HEAD_REF master
)

file(COPY ${SOURCE_PATH}/include/sqlite_orm DESTINATION ${CURRENT_PACKAGES_DIR}/include/)

file(INSTALL
    ${SOURCE_PATH}/LICENSE
    DESTINATION ${CURRENT_PACKAGES_DIR}/share/sqlite-orm RENAME copyright)
