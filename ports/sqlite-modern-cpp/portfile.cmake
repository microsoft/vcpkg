# header only
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO SqliteModernCpp/sqlite_modern_cpp
    REF 936cd0c86aacac87a3dab32906397944ae5f6c3d
    SHA512 8ce1b7593fe77dcab297ab4cae0158b43d55b33c1823b2dc5bf22e5545d9781d675ba5ac82b81782f502b34d2335eee2c26167726746a61a0ad566b657d2faf0
    HEAD_REF master
)

file(INSTALL ${SOURCE_PATH}/hdr/ DESTINATION ${CURRENT_PACKAGES_DIR}/include)

file(MAKE_DIRECTORY ${CURRENT_PACKAGES_DIR}/share/sqlite-modern-cpp)
file(INSTALL ${SOURCE_PATH}/License.txt DESTINATION ${CURRENT_PACKAGES_DIR}/share/sqlite-modern-cpp RENAME copyright)
