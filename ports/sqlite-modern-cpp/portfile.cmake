# header only
include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO SqliteModernCpp/sqlite_modern_cpp
    REF 936cd0c86aacac87a3dab32906397944ae5f6c3d
    SHA512 06a2ded49c397bc5863b08e662a4c980b2bb6ffeaade9ba8ffa34f63e22a95fe2138ba2412b51c6ef5429e2d1110c8dfb085af7e97b2548c2293319caea77bae
    HEAD_REF master
)

file(INSTALL ${SOURCE_PATH}/hdr/ DESTINATION ${CURRENT_PACKAGES_DIR}/include)

file(MAKE_DIRECTORY ${CURRENT_PACKAGES_DIR}/share/sqlite-modern-cpp)
file(INSTALL ${SOURCE_PATH}/License.txt DESTINATION ${CURRENT_PACKAGES_DIR}/share/sqlite-modern-cpp RENAME copyright)
