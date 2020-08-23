# header-only library

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO p-ranav/indicators
    REF ec1973607d5b360b3d1f9b07af851ce236ebd0ae
    SHA512 9b9678129525f03ece91217eb71098b8e14f76f178f9abfd24aa0679bcf7ae27dd600bdba185987e9908dfd8fb5e837dc903a8be011fb08d8707216a3084522a
    HEAD_REF master
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DINDICATORS_BUILD_TESTS=OFF
        -DINDICATORS_SAMPLES=OFF
        -DINDICATORS_DEMO=OFF
)

vcpkg_install_cmake()

vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/indicators TARGET_PATH share/indicators)

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug ${CURRENT_PACKAGES_DIR}/lib)

file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
file(INSTALL ${SOURCE_PATH}/LICENSE.termcolor DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT})
