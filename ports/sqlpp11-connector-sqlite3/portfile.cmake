vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO rbock/sqlpp11-connector-sqlite3
    REF a06d6944a55349fbd0ab0337c45d80c6efa2ff81 # 0.30
    SHA512 51efe8914b5ccf8092e15a9a7b29798db070ce0b47bb87b212724e209149c3a81821a3841ac317f506356430d87d3f16a066c74f60ad1ad7bf1333c9de36916b
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
