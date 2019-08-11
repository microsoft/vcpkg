include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO jherico/basis_universal
    REF 11aa181a4bbf051475a01a1e73e39bf388819215
    SHA512 62d7de6c6ca5e6235c8a377767389a7d5393e05bb5d0c024ce756e77d235132efa48280c9d529b6a91eddf0c906c3c84b6b78fdf339b1a47039b28d04161d2fe
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
