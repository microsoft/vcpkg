vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO FNA-XNA/faudio
    REF "${VERSION}"
    SHA512 1811e59736a053a2b8c4cce75345d3c0fe9f3a7127fe5bc13a562838e9d2ace0b54403f5e4da3d20970e031d69d62e81aa388d8bde72e805dc57ea026a7f1bea
    HEAD_REF master
)

set(options "")
if(VCPKG_TARGET_IS_WINDOWS)
    list(APPEND options -DPLATFORM_WIN32=TRUE)
endif()

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        ${options}
)

vcpkg_cmake_install()
vcpkg_copy_pdbs()
vcpkg_fixup_pkgconfig()

vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/FAudio)

file(REMOVE_RECURSE
    "${CURRENT_PACKAGES_DIR}/debug/include"
    "${CURRENT_PACKAGES_DIR}/debug/share"
)

vcpkg_install_copyright(
    COMMENT "FAudio is licensed under the Zlib license."
    FILE_LIST
       "${SOURCE_PATH}/LICENSE"
)
