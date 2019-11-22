include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO jherico/basis_universal
    REF b0ec54562c215b2f9ed6d54dcaaca9d762d4aff3
    SHA512 27ceb6076c79991639c16bd56a1f81f03fad6d6b4b0184f3f3b594bb163509525e03a7d5f1ba068d186f9cbba677e52972e0b364f4369eadf507fca6e6c60820
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
