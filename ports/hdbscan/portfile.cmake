vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO ooraloo/hdbscan-cpp-vcpkg
    REF "v${VERSION}"
    SHA512 4cf8cc82abd92080cfa4c75fe742770ea5f12bf36c2c81370a301dd82b0cc89357c104995f1050a09a1ab7d5a87b92e20c3d79e4d81e467cc98b744e89dd8c3a
    HEAD_REF "master"
)

vcpkg_cmake_configure(
    SOURCE_PATH ${SOURCE_PATH}
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup()
vcpkg_install_copyright(FILE_LIST ${SOURCE_PATH}/LICENSE.md)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")