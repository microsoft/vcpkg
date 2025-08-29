if(VCPKG_TARGET_IS_WINDOWS)
    vcpkg_check_linkage(ONLY_STATIC_LIBRARY)
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO nianticlabs/spz
    REF v${VERSION}
    SHA512 e1ee9314bd0a698e73db6d02937a20eea9419864d45eaa03e184cd9fca07dc08a92c2dfedf8e2415cbfc1ca3917435eb54ad0badd0f584aeeb2038b3bf7f000a
    HEAD_REF main
    PATCHES
        android-log.diff
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
)

vcpkg_cmake_install()
vcpkg_copy_pdbs()
vcpkg_cmake_config_fixup(CONFIG_PATH "lib/cmake/spz")

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
