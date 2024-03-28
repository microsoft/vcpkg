vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO aliyun/aliyun-oss-c-sdk
    REF ${VERSION}
    SHA512 f92b2dac43bdfe1a5c9fc012325751ee83d6f5c5f5a646ac8606894c458bd9488bc4a56f926218b213cb905becccddd976e8e94a257d77adf4269d48df27638e
    HEAD_REF master
    PATCHES
        patch.patch
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
)

vcpkg_cmake_install()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
