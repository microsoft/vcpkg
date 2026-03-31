vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO facebookincubator/dispenso
    REF "v${VERSION}"
    SHA512 2c1da1e5050cdc788af81aeda44cb5e54a1aa40e85149e24835daf37e4a34c26d794d94f7b8539985f2732a1e9ec8d82c89776ed3c7449710ecaff01586bac9e
    HEAD_REF main
    PATCHES
        fix-arm64-platform-define.patch
)

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "dynamic" DISPENSO_SHARED)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DDISPENSO_BUILD_TESTS=OFF
        -DDISPENSO_BUILD_BENCHMARKS=OFF
        -DDISPENSO_SHARED_LIB=${DISPENSO_SHARED}
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH "lib/cmake/Dispenso-${VERSION}")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
