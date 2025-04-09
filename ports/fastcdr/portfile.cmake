vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO eProsima/Fast-CDR
    REF "v${VERSION}"
    SHA512 93044a36bbef10fc5c52e9c1f86a73da022af1e10652db6e52ead0eea457d45cae5c456b276e034cfa8c2ff6bce41e52ca24031910a816d9871bf3e3c9d3a112
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
