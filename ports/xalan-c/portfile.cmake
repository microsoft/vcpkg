vcpkg_check_linkage(ONLY_DYNAMIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO apache/xalan-c
    REF 177da75646a80fae2c22a315c0d987a5eadba143
    SHA512 e0f095b7031394c39c8e0fdca1f820c4222466f8c6e9df7bc40a21f9ca0e9291b7b6cdfb0a2d67db275ae97d7a7cdd447637102639e74716f0fb23a946b30ebe
    PATCHES
        fix-win-deprecated-err.patch
        fix-missing-dll-error.patch
        fix-linux-no-bin.patch
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS -DCMAKE_DISABLE_FIND_PACKAGE_ICU=ON
)

vcpkg_install_cmake()
vcpkg_copy_tools(TOOL_NAMES Xalan AUTO_CLEAN)

if(EXISTS ${CURRENT_PACKAGES_DIR}/cmake)
    vcpkg_fixup_cmake_targets(CONFIG_PATH cmake TARGET_PATH share/xalanc)
else()
    vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/XalanC TARGET_PATH share/xalanc)
endif()

# cleanup
file(REMOVE_RECURSE
    ${CURRENT_PACKAGES_DIR}/debug/include
    ${CURRENT_PACKAGES_DIR}/debug/share
)

# Handle copyright
file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)

vcpkg_copy_pdbs()
