include("${VCPKG_ROOT_DIR}/ports/vcpkg-cmake/vcpkg-port-config.cmake" OPTIONAL)
include("${VCPKG_ROOT_DIR}/ports/vcpkg-cmake-config/vcpkg-port-config.cmake" OPTIONAL)

vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Alazar42/MSL
    REF "v${VERSION}"
    SHA512 e3212a6543d00b660b82e63ea085cbfe2c6221fffec95d5398b5aaa35723e27d3dae5bf42a9315ae55405419ed8b4ed3f825b1218b82c2a7077806056ef1d24c
    HEAD_REF main
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DMSL_BUILD_TESTS=OFF
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(PACKAGE_NAME "msl" CONFIG_PATH "share/cmake/msl")

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug")

file(TOUCH "${CURRENT_PACKAGES_DIR}/share/${PORT}/usage-accurate")
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
