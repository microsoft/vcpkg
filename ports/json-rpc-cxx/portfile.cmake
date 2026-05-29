vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO jsonrpcx/json-rpc-cxx
    REF "v${VERSION}"
    SHA512 fa4ee807dd29027edd86949a8632adede77c3706406e6b78a8b6e38003f80103082ef70e0b89293a608db238d6f5662669b69cf0cb3d607bcc959c8801c5f3e0
    HEAD_REF master
    PATCHES
       fix-config.patch
)

set(VCPKG_BUILD_TYPE release) # header-only port

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DCOMPILE_TESTS=OFF
        -DCOMPILE_EXAMPLES=OFF
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(PACKAGE_NAME unofficial-${PORT})
file(READ "${CURRENT_PACKAGES_DIR}/share/unofficial-${PORT}/unofficial-${PORT}-config.cmake" JSON_RPC_CXX_CONFIG)
file(WRITE "${CURRENT_PACKAGES_DIR}/share/unofficial-${PORT}/unofficial-${PORT}-config.cmake" "
include(CMakeFindDependencyMacro)
find_dependency(nlohmann_json)
${JSON_RPC_CXX_CONFIG}
")

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/lib")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
