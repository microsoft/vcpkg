vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO stlab/copy-on-write
    REF "v${VERSION}"
    SHA512 c7e9036862aafb1cc651eb8785edb09c11b36245731fb0213d6cc72c7cf521cd5954e6fd40aa5349148e103f847e62c0736ea943e5f097b46e96c5ba0a125151
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
    SHA512 c7e9036862aafb1cc651eb8785edb09c11b36245731fb0213d6cc72c7cf521cd5954e6fd40aa5349148e103f847e62c0736ea943e5f097b46e96c5ba0a125151
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
