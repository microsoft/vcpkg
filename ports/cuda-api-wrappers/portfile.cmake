vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO eyalroz/cuda-api-wrappers
    REF "v${VERSION}"
    SHA512 71170b59a116a886c319f6409204d610636a16148754a9811a8c608912b14c09f5f9037b9366c2d0a012c3fd88b5c90d289ce3da692663f1a86f3c3f2bbd7b02
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
