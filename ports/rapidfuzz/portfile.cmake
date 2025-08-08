vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO maxbachmann/rapidfuzz-cpp
    REF "v${VERSION}"
    SHA512 4befcf9a22e2f478a93fb3e8f6a1b954071c707ee339f2d0a0e0367d24eb35670213b98e48d0d3956f50e4c7554ce326e4dd64470d706afafe4d2252f216ea48
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
