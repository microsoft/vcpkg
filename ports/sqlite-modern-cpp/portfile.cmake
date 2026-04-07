# header only
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO SqliteModernCpp/sqlite_modern_cpp
    REF 6e3009973025e0016d5573529067714201338c80
    SHA512 a007c739e00b9bd51d19f3bc484709f9fc4637f0262b636b51ee95cbc7f3f7fe6551dcbf0990a0430ac12f276bb72d1e0a3b71f06ac6e6d19fb46d51066a4295
    HEAD_REF master
)

file(INSTALL ${SOURCE_PATH}/hdr/ DESTINATION ${CURRENT_PACKAGES_DIR}/include)

file(MAKE_DIRECTORY ${CURRENT_PACKAGES_DIR}/share/sqlite-modern-cpp)
file(INSTALL ${SOURCE_PATH}/License.txt DESTINATION ${CURRENT_PACKAGES_DIR}/share/sqlite-modern-cpp RENAME copyright)
