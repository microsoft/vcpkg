include(vcpkg_common_functions)

vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO google/double-conversion
    REF 5fa81e88ef24e735b4283b8f7454dc59693ac1fc
    SHA512 7ee96273a327d380f5a2ab7e8865747a3336fe27a71cc2a797b775cdfbe7019bf288000edbd1451c242cfbb7a4a39ea046c528204886e4fd45eecd1595795090
    HEAD_REF master
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
)

vcpkg_install_cmake()

# Rename exported target files into something vcpkg_fixup_cmake_targets expects
if(EXISTS ${CURRENT_PACKAGES_DIR}/lib/cmake/double-conversion)
    vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/double-conversion)
endif()

vcpkg_copy_pdbs()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

# Handle copyright
configure_file(${SOURCE_PATH}/LICENSE ${CURRENT_PACKAGES_DIR}/share/double-conversion/copyright COPYONLY)
