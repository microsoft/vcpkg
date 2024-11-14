vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO maxbachmann/rapidfuzz-cpp
    REF "v${VERSION}"
    SHA512 204ee06c1e51b786f0a2efd32a1c2467c3bff2738e8258e6e8fe44b5569afe7c665af1051fdd05dcc98704f3045f5bd2afcba5dba3fc0b34e2facf8944478b48
    HEAD_REF master
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/${PORT})

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/lib/")
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
