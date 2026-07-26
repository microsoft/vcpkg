vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO bhouvana/Chronicle
    REF "v${VERSION}"
    SHA512 f7a496592367e0ad7486e6562bd3a01734093395420f857802759217d3b70ebcb8a7cb400ba134d289468a2fc6c81dae385c7d22272672ab937e5b6b8a1a6e2c
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
