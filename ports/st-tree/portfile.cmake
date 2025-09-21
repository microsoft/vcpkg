vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO erikerlandson/st_tree
    REF "version_${VERSION}"
    SHA512 354181bf397d92a863fcb46a6c07aec44599720456f61d639b3f0df4b95a6f908d0d44d3b2a430b3ef5a30c5df24ad29f638c4f8f80e51682d3eee800cfeea57
    HEAD_REF develop
)

set(VCPKG_BUILD_TYPE release) # header-only port

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DBUILD_EXAMPLES=OFF
        -DENABLE_TESTS=OFF
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH "lib/cmake" PACKAGE_NAME st_tree)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/lib")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
