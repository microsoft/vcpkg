set(VCPKG_BUILD_TYPE release) # header-only library

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO MitchellThompkins/consteig
    REF "${VERSION}"
    SHA512 faf57dc6c9f0106879b0cc12c248c26bdc1313ea60101e139b5cae7bffbc8376e5f92e2fe74f81fee7801dc5ff2a4c3a1ab5ca61e6c74d1cf8e58d3e6fc613c0
    HEAD_REF main
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        "-DCONSTEIG_VERSION=${VERSION}"
        -DCONSTEIG_BUILD_TESTS=OFF
        -DCONSTEIG_BUILD_EXAMPLES=OFF
        -DCONSTEIG_BUILD_PROFILING=OFF
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/consteig)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/lib")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
