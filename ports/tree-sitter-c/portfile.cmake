if(VCPKG_TARGET_IS_WINDOWS)
    vcpkg_check_linkage(ONLY_STATIC_LIBRARY)
endif()

# Don't change to vcpkg_from_github! The distfile includes a generated parser.c.
vcpkg_download_distfile(ARCHIVE
    URLS "https://github.com/tree-sitter/tree-sitter-c/releases/download/v${VERSION}/tree-sitter-c.tar.gz"
    FILENAME "tree-sitter-c-${VERSION}.tar.gz"
    SHA512 03d28ceb90750e881633057c366091466c31a839b7479f08fd58c753a962782678a851c3da4063136727f5cd60e86af836f32fe219b07d480ea768f07c18c7e2
)

#[[ # Uses cmake -E tar ..., but fails to extract this file
vcpkg_extract_source_archive(SOURCE_PATH
    ARCHIVE "${ARCHIVE}"
    PATCHES
        ...
)
]]
set(SOURCE_PATH "${CURRENT_BUILDTREES_DIR}/src/v${VERSION}")
file(REMOVE_RECURSE "${SOURCE_PATH}")
file(MAKE_DIRECTORY "${SOURCE_PATH}")
vcpkg_execute_in_download_mode(
    COMMAND tar xzf "${ARCHIVE}"
    WORKING_DIRECTORY "${SOURCE_PATH}"
)
vcpkg_apply_patches(
    SOURCE_PATH "${SOURCE_PATH}"
    PATCHES
        avoid-cli.diff
        pkgconfig.diff
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DTREE_SITTER_REUSE_ALLOCATOR=ON
)
vcpkg_cmake_install()
vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
