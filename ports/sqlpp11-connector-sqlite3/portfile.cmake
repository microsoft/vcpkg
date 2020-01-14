include(vcpkg_common_functions)

vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO rbock/sqlpp11-connector-sqlite3
    REF 0.29
    SHA512 99d1b36209dc879b12b99ed0809f1d21f760c62c25aa32d8f83b571d0819e35783ad20be0754288da9cd5fcb81cbb672031928d159ff9a64c3635dcbc4bda8fa
    HEAD_REF master
)

# Use sqlpp11-connector-sqlite3's own build process, skipping tests
vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DENABLE_TESTS:BOOL=OFF
        -DSQLPP11_INCLUDE_DIR=${CURRENT_INSTALLED_DIR}/include
)

vcpkg_install_cmake()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

# Handle copyright
file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/sqlpp11-connector-sqlite3 RENAME copyright)
