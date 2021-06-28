vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO albertodemichelis/squirrel
    HEAD_REF master
    REF cf0516720e1fa15c8cbd649aebd1924f6e7084cc
    SHA512 6127d25e40217188abe14e30943f131f0e03923cf095f3df276a9c36b48495cf5d84bb1e30b39fa23bd630d905b6a6b4c70685dfb7a999b8b0c12e28c2e3b902 # 0462bf5a4347ad9c24d8372122ac1b4474d9c80cbcac8523a08a671232688f7193ea2c8b7f05088ad9d6a0dbb8c893b1e8e640185a326be75efdd86e813c5016
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
)

vcpkg_install_cmake()

vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/squirrel TARGET_PATH share/squirrel)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/bin")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/bin")

file(INSTALL ${SOURCE_PATH}/COPYRIGHT DESTINATION ${CURRENT_PACKAGES_DIR}/share/squirrel RENAME copyright)
