include(vcpkg_common_functions)

vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/eastl)
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO electronicarts/EASTL
    REF dcd2b838d52de13691999aff8faeaa8f284928ac
    SHA512 9756ee47a30447f17ceb45fb5143d6e80905636cf709c171059a83f74094fb25391c896de0ea5e063cdad4e7334c5f963c75b1c34ad539fd24175983a2054159
    HEAD_REF master
    PATCHES fixchar8_t.patch # can be removed after electronicarts/EASTL#274 is resolved
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
)

vcpkg_install_cmake()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

vcpkg_copy_pdbs()

# Handle copyright
file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/eastl RENAME copyright)
file(INSTALL ${SOURCE_PATH}/3RDPARTYLICENSES.TXT DESTINATION ${CURRENT_PACKAGES_DIR}/share/eastl)
