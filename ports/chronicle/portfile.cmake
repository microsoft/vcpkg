vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO bhouvana/Chronicle
    REF "v${VERSION}"
    SHA512 90d36948f5227cf6b1f41d849b05c182a354bfa28bd13376e7bd779241435a5c9c752cb4f4b99c240a576acbf23264dd0c53f7acd5a0575c60e97d0a08f61ef9
    HEAD_REF main
)

set(VCPKG_BUILD_TYPE release) # header-only port

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DCHRONICLE_BUILD_TESTS=OFF
        -DCHRONICLE_BUILD_EXAMPLES=OFF
        -DCHRONICLE_BUILD_BENCH=OFF
        -DCHRONICLE_BUILD_TOOLS=OFF
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/chronicle)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/lib")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
