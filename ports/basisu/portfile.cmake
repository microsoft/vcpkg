include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO jherico/basis_universal
    REF d303a93f48606829378dd413142d5e1ea744021c
    SHA512 aeb29f60904eb19840748a1d6b1b11cd61828362df06c8715d59c7c1556bcd5f78b962dd02bf738249277346a357d2d0f53e0432015eee74978416a1e7e68272
    HEAD_REF master
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DBUILD_TESTS=OFF
)

vcpkg_install_cmake()

#vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/basisu)
if (WIN32)
    set(TOOL_NAME basisu_tool.exe)
else()
    set(TOOL_NAME basisu_tool)
endif()

file(COPY ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/basisu)
file(COPY ${CURRENT_PACKAGES_DIR}/bin/${TOOL_NAME} DESTINATION ${CURRENT_PACKAGES_DIR}/tools/basisu)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/basisu/LICENSE ${CURRENT_PACKAGES_DIR}/share/basisu/copyright)

vcpkg_copy_tool_dependencies(${CURRENT_PACKAGES_DIR}/tools/basisu)

# Remove unnecessary files
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(REMOVE ${CURRENT_PACKAGES_DIR}/debug/bin/${TOOL_NAME})
file(REMOVE ${CURRENT_PACKAGES_DIR}/bin/${TOOL_NAME})

if(VCPKG_LIBRARY_LINKAGE STREQUAL static)
    file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/bin ${CURRENT_PACKAGES_DIR}/debug/bin)
endif()

vcpkg_copy_pdbs()
