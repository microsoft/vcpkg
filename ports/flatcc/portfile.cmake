if(VCPKG_TARGET_IS_WINDOWS)
    vcpkg_check_linkage(ONLY_STATIC_LIBRARY)
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO dvidelabs/flatcc
    REF "v${VERSION}"
    SHA512 7640fe434f4fd782652033c642c72160f331457baf34f59d55ab2628e036373a054cb7b237242d6605ec0353e9a0b64b9e5c422224a42627150c9e549885fac4
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
