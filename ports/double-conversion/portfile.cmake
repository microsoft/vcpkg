include(vcpkg_common_functions)

vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO google/double-conversion
    REF v3.1.4
    SHA512 715a34ace2ff74b79d80a8c003c16cfbf958ebc92264e28cc572e1a12a786e1df9678abb46f032c2be387495e1a3d02957b12fa4a245ec6cfe19ca637519ac3c
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
