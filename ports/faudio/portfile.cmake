vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO FNA-XNA/faudio
    REF "${VERSION}"
    SHA512 2d9f7c93bc6d82934765d2e1468ce4facbe0396cf7905dca4de4b178cf5eabcb0535a8380d27c40bb8f5c72473e1a8af4791dd81931571102c333dcbd44cbdc2
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
