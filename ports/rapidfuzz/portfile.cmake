vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO maxbachmann/rapidfuzz-cpp
    REF "v${VERSION}"
    SHA512 02af141b123545303d634ffe84fbe83e635f06c9ffa3a6506661e53beb22fe7221942b3e46d33b2a49ef929c5de9acfb00c48cb5685c760506c5fcf37c716f9a
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
