set(VCPKG_BUILD_TYPE release) # header only library

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO SlickQuant/slick-dynamic-buffer
    REF "v${VERSION}"
    SHA512 480195e81d357a0f2176e6af13059c10a7fc840d63ca8f9001b562da78e57241809cea1b38e7b82233a2d41a56ee6a1d705ef9a8b8acd9f205d4785a58c400f8
    HEAD_REF main
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DBUILD_SLICK_DYNAMIC_BUFFER_TESTS=OFF
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(
    CONFIG_PATH lib/cmake/slick-dynamic-buffer
)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/lib")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
