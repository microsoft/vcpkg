if(VCPKG_TARGET_IS_WINDOWS)
    vcpkg_check_linkage(ONLY_STATIC_LIBRARY)
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO tree-sitter/tree-sitter-c
    REF "v${VERSION}"
    SHA512 daa56178adfc4cc7931fb2810367e531113e07ebadcf51cdf7645281627cb86c028c5bb32a1306d294e79d314ef19ce185dfd8786732d5c81a9f3c870396249c
    HEAD_REF master
    PATCHES
        pkgconfig.diff
)

find_program(NODEJS
    NAMES node
    PATHS
        "${CURRENT_HOST_INSTALLED_DIR}/tools/node"
        "${CURRENT_HOST_INSTALLED_DIR}/tools/node/bin"
        ENV PATH
    NO_DEFAULT_PATH
    REQUIRED
)
get_filename_component(NODEJS_DIR "${NODEJS}" DIRECTORY)
vcpkg_add_to_path(PREPEND "${NODEJS_DIR}")

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        "-DTREE_SITTER_CLI=${CURRENT_HOST_INSTALLED_DIR}/tools/tree-sitter-cli/tree-sitter${VCPKG_HOST_EXECUTABLE_SUFFIX}"
        -DTREE_SITTER_REUSE_ALLOCATOR=ON
)
vcpkg_cmake_install()
vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
