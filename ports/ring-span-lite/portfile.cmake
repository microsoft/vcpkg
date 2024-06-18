vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO martinmoene/ring-span-lite
    REF "v${VERSION}"
    SHA512 aa3f199e4cef36ead644d9620e716c2f91bbb52fe3193919ed6aec099bc32841168eaf789c8ddc6700688a34335ad04e139822633d7e26184f511431ca4aaa12
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DRING_SPAN_LITE_OPT_BUILD_TESTS=OFF
        -DRING_SPAN_LITE_OPT_BUILD_EXAMPLES=OFF
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(
    CONFIG_PATH "lib/cmake/${PORT}"
)

file(REMOVE_RECURSE
    "${CURRENT_PACKAGES_DIR}/debug"
    "${CURRENT_PACKAGES_DIR}/lib"
)

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE.txt")
