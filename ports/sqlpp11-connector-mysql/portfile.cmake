vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO rbock/sqlpp11-connector-mysql
    REF 0.29
    SHA512 0c71d2ea94933be3bbaa8d6afaac7059660bdb0af5ba905844d95facb5e73a122c3ccd723a48a7fd8db0c028309ac6dc8b91c6838dfbfe530727161d62a1481f
    HEAD_REF master
)

# Use sqlpp11-connector-mysql's own build process, skipping tests
vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DENABLE_TESTS:BOOL=OFF
        -DDATE_INCLUDE_DIR=${CURRENT_INSTALLED_DIR}/include
        -DSQLPP11_INCLUDE_DIR=${CURRENT_INSTALLED_DIR}/include
        -DMYSQL_INCLUDE_DIR=${CURRENT_INSTALLED_DIR}/include/mysql
)

vcpkg_install_cmake()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

# Handle copyright
file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/sqlpp11-connector-mysql RENAME copyright)
