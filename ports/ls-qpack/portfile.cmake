if(VCPKG_TARGET_IS_WINDOWS)
    vcpkg_check_linkage(ONLY_STATIC_LIBRARY)
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO litespeedtech/ls-qpack
    REF "v${VERSION}"
    SHA512 74d4b2ea96bf0de43009cc121c8e57caff83be53c613236b01dce4ac4c12505d0d9fec07d9152ca62166947a160de2ab3f7bf19fb203a60b44507516a927ecb8
    HEAD_REF master
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
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/ls-qpack)

file(REMOVE_RECURSE 
    "${CURRENT_PACKAGES_DIR}/debug/include"
    "${CURRENT_PACKAGES_DIR}/debug/share"
)

file(READ "${CURRENT_PACKAGES_DIR}/share/ls-qpack/ls-qpack-config.cmake" cmake_config)
file(WRITE "${CURRENT_PACKAGES_DIR}/share/ls-qpack/ls-qpack-config.cmake"
"include(CMakeFindDependencyMacro)
find_dependency(PkgConfig)
pkg_check_modules(XXH REQUIRED IMPORTED_TARGET libxxhash)
${cmake_config}
")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
