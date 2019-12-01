include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO garyhouston/rxspencer
    REF alpha3.8.g7
    SHA512 6c0b8c91d841a0d1a80c4feb22b299d3fa217e974cd22d4752ef8f29d21366571549ebb2b6a2dc2d519c57e8d1f035c388822f896bd65ba30044547eb43b0aa8
    HEAD_REF master
    PATCHES 0001-Add-CMake-build-scripts-derived-from-LuaDist.patch
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS -DCMAKE_CONFIG_DEST=share/rxspencer
)

vcpkg_install_cmake()

vcpkg_fixup_cmake_targets(CONFIG_PATH "share/rxspencer")

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/share/regex)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)

# Handle copyright
file(INSTALL ${SOURCE_PATH}/COPYRIGHT DESTINATION ${CURRENT_PACKAGES_DIR}/share/rxspencer RENAME copyright)

vcpkg_copy_pdbs()
