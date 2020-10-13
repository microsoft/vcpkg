include(vcpkg_common_functions)

if(VCPKG_LIBRARY_LINKAGE STREQUAL dynamic)
    set(ADDITIONAL_PATCH "shared.patch")
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO mm2/Little-CMS
    REF 17eb080324a9f16e0e7ab37bbcda7ae42b946294 # 2.11
    SHA512 e8112bc4868448770d3ca33fc5aef5ef83cae59e907675b861931719a6a043df76a1ce72ac945111ce966698be96117388eb4770697797d93d75726b23a490ad
    HEAD_REF master
    PATCHES
        remove_library_directive.patch
        ${ADDITIONAL_PATCH}
)

file(COPY ${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt DESTINATION ${SOURCE_PATH})

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
)

vcpkg_install_cmake()
vcpkg_copy_pdbs()
vcpkg_fixup_cmake_targets()
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

file(INSTALL ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/lcms RENAME copyright)
