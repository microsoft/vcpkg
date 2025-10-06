vcpkg_check_linkage(ONLY_DYNAMIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO nibanks/msh3
    REF v${VERSION}
    SHA512 ac35ab8c5145b1285a23cf847d5ee2fef5c706c034d89877c09d0f4d8961cc08e7926fe2ba40698d42968635b002b3234906ece0d4866786febfe6d3ba95382d
    HEAD_REF main
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DMSH3_INSTALL_PKGCONFIG=ON
        -DMSH3_USE_EXTERNAL_LSQPACK=ON
        -DMSH3_USE_EXTERNAL_MSQUIC=ON
)

vcpkg_cmake_install()
vcpkg_copy_pdbs()
vcpkg_fixup_pkgconfig()
vcpkg_cmake_config_fixup()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
