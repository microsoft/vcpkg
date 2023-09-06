if(VCPKG_TARGET_IS_WINDOWS)
    vcpkg_check_linkage(ONLY_STATIC_LIBRARY)
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO mattgodbolt/seasocks
    REF "v${VERSION}"
    SHA512 733e12e57db025797016a49fa191facb72a0aa57625545c613862f407b21f8c19f78fc633a9a004d7ff15ded87e9a9a379c5fff2f92a14ccf83f0ff7d2308561
    HEAD_REF master
    PATCHES
        0001-fix-x86-build.patch
)

vcpkg_find_acquire_program(PYTHON3)
get_filename_component(PYTHON3_DIR "${PYTHON3}" DIRECTORY)
vcpkg_add_to_path("${PYTHON3_DIR}")

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        zlib DEFLATE_SUPPORT
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DUNITTESTS=OFF
        -DSEASOCKS_EXAMPLE_APP=OFF
        ${FEATURE_OPTIONS}
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(CONFIG_PATH "lib/cmake/Seasocks")

vcpkg_copy_pdbs()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/share/licenses")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
