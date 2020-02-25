include(vcpkg_common_functions)

vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO rbock/sqlpp11-connector-mysql
    REF 243096a1d2619d409a4be8d869ff9d3d3f8e6ccb # 0.26
    SHA512 518b2fec292759f229c5758508dc7413594840b56eb7232e0c5e3013e60941eeb9d9f4e4edfe98981f447848e08234bbf686362a93eac51c70cd9ed87150b54e
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
