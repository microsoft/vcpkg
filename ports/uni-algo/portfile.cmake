vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO uni-algo/uni-algo
    REF "v${VERSION}"
    SHA512 262f02acd56e96f0e4b4ba3d9793f2cab65c124d431add56fca2a7793c41c4cac7cd364395d4e84937e09f6c682366cca8228886388c8cc021b2ff2483f58652
    HEAD_REF main
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DUNI_ALGO_INSTALL=ON
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(NO_PREFIX_CORRECTION)

vcpkg_copy_pdbs()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE.md")
file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
