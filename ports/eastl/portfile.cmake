include(vcpkg_common_functions)

vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO electronicarts/EABase
    REF 6f27a2f7aa21f2d71ae8c6bc1d889d0119677a56
    SHA512 9176fb2d508cf023c3c16c61a511196a2f6af36172145544bba44062a00ca7591e54e4fc16ac13562ef0e2d629b626f398bff3669b4cdb7ba0068548d6a53883
    HEAD_REF master
    PATCHES
    fix_uwp.patch
)

set(EABASE_PATH  ${SOURCE_PATH})

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO electronicarts/EASTL
    REF dcd2b838d52de13691999aff8faeaa8f284928ac
    SHA512 9756ee47a30447f17ceb45fb5143d6e80905636cf709c171059a83f74094fb25391c896de0ea5e063cdad4e7334c5f963c75b1c34ad539fd24175983a2054159
    HEAD_REF master
    PATCHES 
    fixchar8_t.patch # can be removed after electronicarts/EASTL#274 is resolved
    fix_cmake_install.patch
)

file(COPY ${EABASE_PATH}/include/Common/EABase/ DESTINATION ${SOURCE_PATH}/test/packages/EABase)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
    -DEASTL_BUILD_TESTS=OFF
    -DEASTL_BUILD_BENCHMARK=OFF
)

vcpkg_install_cmake()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

vcpkg_copy_pdbs()

# Handle copyright
file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/eastl RENAME copyright)
file(INSTALL ${SOURCE_PATH}/3RDPARTYLICENSES.TXT DESTINATION ${CURRENT_PACKAGES_DIR}/share/eastl)
