vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO stlab/copy-on-write
    REF "v${VERSION}"
    SHA512 4f480b35a232abd94f70bcd37b93099196e8d09f40678f87afc367af7b11c5799ffaa81ee134e6c1b85f7a5d6765f0a25c305d6dd09685bb1b4bbc3948ecbd3e
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
    OPTIONS
        -DBUILD_TESTING=OFF
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/stlab-copy-on-write)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/lib")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
