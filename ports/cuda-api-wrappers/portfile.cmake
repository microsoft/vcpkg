vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO eyalroz/cuda-api-wrappers
    REF "v${VERSION}"
    SHA512 14df77c3d613500e57f223fb692b04ea89c6b6b4ba9ecc1b58059e1b2970acaa8986cb55f3f090d305a3fe6136a83d2a8cf0bb88e02be691456fcef1b1867ef9
    HEAD_REF master
)

# head only library
set(VCPKG_BUILD_TYPE release)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DCAW_BUILD_EXAMPLES=OFF
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/${PORT})

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/lib")

file(COPY "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
