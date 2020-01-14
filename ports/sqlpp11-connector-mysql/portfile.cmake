include(vcpkg_common_functions)

vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO rbock/sqlpp11-connector-mysql
    REF 0.25
    SHA512 1351161eff5ecc3c2bc720f537e474fadc8f4843999e33274a9b1bccf21fd2b5785eb9588dedc951dcf1c09e4a90c8e2193e9046a43a1bc9d355045aaec71740
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
