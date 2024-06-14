vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO actor-framework/actor-framework
    REF "${VERSION}"
    SHA512 8a7aacbd9bf18318d9ca1f5fb30c101220c1eef2c4bfe82c53760024022473109038872c0deb5a60d732a91da8d863c556a27018e6b667bfcfbf536df3cebcaf
    HEAD_REF master
    PATCHES
        fix_dependency.patch
        fix_cxx17.patch
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DCMAKE_DISABLE_FIND_PACKAGE_Doxygen=ON
        -DCAF_ENABLE_CURL_EXAMPLES=OFF
        -DCAF_ENABLE_PROTOBUF_EXAMPLES=OFF
        -DCAF_ENABLE_QT6_EXAMPLES=OFF
        -DCAF_ENABLE_RUNTIME_CHECKS=OFF
        -DCAF_ENABLE_ACTOR_PROFILER=OFF
        -DCAF_ENABLE_EXAMPLES=OFF
        -DCAF_ENABLE_TESTING=OFF
        -DCAF_ENABLE_TOOLS=OFF
        -DCAF_ENABLE_IO_MODULE=ON
        -DCAF_ENABLE_EXCEPTIONS=ON
        -DCAF_ENABLE_UTILITY_TARGETS=OFF
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(PACKAGE_NAME CAF CONFIG_PATH lib/cmake/CAF)

vcpkg_copy_pdbs()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include" "${CURRENT_PACKAGES_DIR}/debug/share")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
