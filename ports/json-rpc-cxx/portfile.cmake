vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO jsonrpcx/json-rpc-cxx
    REF "v${VERSION}"
    SHA512 0b8f2b1c8ff95bee14585f6b363f6aa4bf046e3905f7a65cf2e562e5c9181a3ba882baded36fab4d3ff9ac5b2f3245eeb54260f2163491af7fba264ff547f6d8
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
