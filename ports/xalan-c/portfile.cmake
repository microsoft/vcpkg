include(vcpkg_common_functions)

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
)

vcpkg_install_cmake()

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

if(VCPKG_LIBRARY_LINKAGE STREQUAL static)
    file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/bin ${CURRENT_PACKAGES_DIR}/debug/bin)
else()
    file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/bin/Xalan.exe ${CURRENT_PACKAGES_DIR}/debug/bin/Xalan.exe)
endif()	

# Handle copyright
file(COPY ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/xalan-c)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/xalan-c/LICENSE ${CURRENT_PACKAGES_DIR}/share/xalan-c/copyright)

vcpkg_copy_pdbs()
