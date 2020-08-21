#Blocked by ninja: error: build.ninja:348: multiple rules generate lib/redis++.lib [-w dupbuild=err]
vcpkg_fail_port_install(ON_TARGET "Windows")

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO sewenew/redis-plus-plus
    REF b08b36a9a91de00636e583307610f49af7876f50 # 1.1.2
    SHA512 6dcead9fca9e7082ace28dcd72a1b325e229297080eea3e5a28ef5e6b9e4a7d1bcb3568997a5e7a031d7937a025a017ed92d7869db5829ba6113783c84bc5a68
    HEAD_REF master
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DREDIS_PLUS_PLUS_BUILD_TEST=OFF
)

vcpkg_install_cmake()

vcpkg_copy_pdbs()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

# Handle copyright
file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright )