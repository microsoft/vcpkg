vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO jherico/basis_universal
    REF 497875f756ed0e3eb62e0ff08d55c62242f4be74
    SHA512 2293b78620a7ed510dbecf48bcae5f4b8524fe9020f864c8e79cf94ea9d95d51dddf83a5b4ea29cc95db19f87137bfef1cb68b7fbc6387e08bb42898d81c9303
    HEAD_REF master
    PATCHES fix-addostream.patch
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

file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
file(COPY ${CURRENT_PACKAGES_DIR}/bin/${TOOL_NAME} DESTINATION ${CURRENT_PACKAGES_DIR}/tools/basisu)

vcpkg_copy_tool_dependencies(${CURRENT_PACKAGES_DIR}/tools/basisu)

# Remove unnecessary files
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(REMOVE ${CURRENT_PACKAGES_DIR}/debug/bin/${TOOL_NAME})
file(REMOVE ${CURRENT_PACKAGES_DIR}/bin/${TOOL_NAME})

if(VCPKG_LIBRARY_LINKAGE STREQUAL static)
    file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/bin ${CURRENT_PACKAGES_DIR}/debug/bin)
endif()

vcpkg_copy_pdbs()
