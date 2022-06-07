vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO saucer/saucer
    REF b116c2040d1e85a7e208d520c0f4fcdfd0289e16
    SHA512 f832dcb02b3bb0d1bded5b5fc14620355cbdac5cf4ff59ea3fef78cbf8d6313ce1e0331b5d883299972721f487844f2f17afc8408154756287963018555de195
    HEAD_REF master
)

vcpkg_cmake_configure(
    SOURCE_PATH ${SOURCE_PATH} 
    OPTIONS -Dsaucer_prefer_remote=OFF
)

vcpkg_cmake_install()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
