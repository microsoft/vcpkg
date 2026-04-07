vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO eProsima/Fast-CDR
    REF "v${VERSION}"
    SHA512 cdf13b4801ec9a5dcc7f5b30963db75645f6e0287d4dbac46dbc2eb8e3881a5cdd4318f71178e3903b40fcddcc2b6d70a4a66ac2b5cf8a2e29161e1e0b1a5a94
    HEAD_REF master
    PATCHES
        pdb-file.patch
)

vcpkg_cmake_configure(
    SOURCE_PATH ${SOURCE_PATH})

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/fastcdr)

vcpkg_copy_pdbs()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include ${CURRENT_PACKAGES_DIR}/lib/fastcdr ${CURRENT_PACKAGES_DIR}/debug/lib/fastcdr)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)

if(VCPKG_LIBRARY_LINKAGE STREQUAL "dynamic")
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/include/fastcdr/eProsima_auto_link.h" "(defined(_DLL) || defined(_RTLDLL)) && defined(EPROSIMA_DYN_LINK)" "1")
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/include/fastcdr/fastcdr_dll.h" "defined(FASTCDR_DYN_LINK)" "1")
endif()

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
