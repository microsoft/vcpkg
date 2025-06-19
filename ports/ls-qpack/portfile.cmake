if(VCPKG_TARGET_IS_WINDOWS)
    vcpkg_check_linkage(ONLY_STATIC_LIBRARY)
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO litespeedtech/ls-qpack
    REF "v${VERSION}"
    SHA512 9b38ba1b4b12d921385a285e8c833a0ae9cdcc153cff4f1857f88ceb82174304decb5fccbdf9267d08a21c5a26c71fdd884dcacd12afd19256a347a8306b9b90
    HEAD_REF master
)
file(REMOVE_RECURSE "${SOURCE_PATH}/deps")

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
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

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
