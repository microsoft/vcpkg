if(VCPKG_TARGET_IS_WINDOWS)
    vcpkg_check_linkage(ONLY_STATIC_LIBRARY)
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO litespeedtech/ls-qpack
    REF "v${VERSION}"
    SHA512 7677f673b4b23a68ad5e899706f17536777b30d7e91c63d3ea97504a6a2885cf7f431c191ac0581631723151050f914ec31bcb84e2b6e3fcdf4140cde0a18063
    HEAD_REF master
    PATCHES
        xxhash.patch
        cmake-export.patch
)

vcpkg_find_acquire_program(PKGCONFIG)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        "-DPKG_CONFIG_EXECUTABLE=${PKGCONFIG}"
        -DLSQPACK_TESTS=OFF
        -DLSQPACK_BIN=OFF
        -DLSQPACK_XXH=OFF
)

vcpkg_cmake_install()
vcpkg_copy_pdbs()
vcpkg_fixup_pkgconfig()
vcpkg_cmake_config_fixup(PACKAGE_NAME unofficial-ls-qpack)

file(REMOVE_RECURSE 
    "${CURRENT_PACKAGES_DIR}/debug/include"
    "${CURRENT_PACKAGES_DIR}/debug/share"
)

file(READ "${CURRENT_PACKAGES_DIR}/share/unofficial-ls-qpack/unofficial-ls-qpack-config.cmake" cmake_config)
file(WRITE "${CURRENT_PACKAGES_DIR}/share/unofficial-ls-qpack/unofficial-ls-qpack-config.cmake"
"include(CMakeFindDependencyMacro)
find_dependency(PkgConfig)
pkg_check_modules(XXH REQUIRED IMPORTED_TARGET libxxhash)
${cmake_config}
")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
