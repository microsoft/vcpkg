include(vcpkg_common_functions)

# volk is not prepared to be a DLL.
vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO zeux/volk
    REF d6c2bde94f70506240eac22763cf3adf930cedf5
    SHA512 ef82e00883d873cf895e71539b26bb5f650c0ad6888171177e72323e69a80d3b6767b73bae086b93f2bec144c1d95cc169b5bb8faf4ad0bca600a6ad623942dc
    HEAD_REF master
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
)
vcpkg_install_cmake()
vcpkg_copy_pdbs()
vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/volk)

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

# Put the file containing the license where vcpkg expects it
file(COPY ${SOURCE_PATH}/README.md DESTINATION ${CURRENT_PACKAGES_DIR}/share/volk/)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/volk/README.md ${CURRENT_PACKAGES_DIR}/share/volk/copyright)
