if(VCPKG_TARGET_IS_WINDOWS)
    vcpkg_check_linkage(ONLY_STATIC_LIBRARY)
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO dvidelabs/flatcc
    REF 29201734bf2d12713a7a1a035d31e5123aac9c93
    SHA512 8c69259b3f314b9ce63e8930f4de9bcd38b164b96d77ad57c748a73510a606749ef40d2b5115c494f7806f8fe86c31b68e5fc3c476f7bca8d7fd70cfcefbe9ce
    HEAD_REF master
    PATCHES
        fix_install_dir.patch
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DFLATCC_INSTALL=ON
        -DFLATCC_ALLOW_WERROR=OFF
        -DFLATCC_TEST=OFF
        -DFLATCC_CXX_TEST=OFF
        -DFLATCC_RTONLY=ON
        -DFLATCC_DEBUG_CLANG_SANITIZE=OFF
        ${EXTRA_OPTIONS}
)

vcpkg_cmake_install()
vcpkg_copy_pdbs()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
