vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO stlab/stlab-enum-ops
    REF "v${VERSION}"
    SHA512 d3aa11cfc2f2b7931e9e41ee661dbc5770023de12ebf0d1823bcdc063d2c57a393be18a214747cbc25296c0268e2b536b102b4bcecb863a12ecfba8badfd613d
    HEAD_REF main
    PATCHES
        disable-cpm.patch
        disable-tests.patch
)

# Replace CPM and download cpp-library directly to avoid issues with FETCHCONTENT_FULLY_DISCONNECTED
vcpkg_from_github(
    OUT_SOURCE_PATH PACKAGE_PROJECT_PATH
    REPO stlab/cpp-library
    REF "v5.0.0"
    SHA512 5e158dbdcabe698f7ddaff460a68c490978a7f91af8cb90f19430456acc1ca0f115973f149303b07d5ed0fbb3b43cd857b133c46bc6b4e8cc96c1ee25b0e87a9
    HEAD_REF master
)
file(RENAME "${PACKAGE_PROJECT_PATH}" "${SOURCE_PATH}/cmake/cpp-library")

set(VCPKG_BUILD_TYPE release) # header-only port

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/stlab-enum-ops)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/lib")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
