include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO google/double-conversion
    REF 3.1.0
    SHA512 ba797a7203bc7eb8ba697dc758a3341578f0405b5ab42fbd5a22d9fac09d11dd8cb5ed9ff9ff369e8ae9397ec74c04c62fca29d1bc469c6d2ea1a84a6dff9188
    HEAD_REF master
)

vcpkg_apply_patches(
    SOURCE_PATH ${SOURCE_PATH}
    PATCHES ${CMAKE_CURRENT_LIST_DIR}/001-fix-arm.patch
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DCMAKE_WINDOWS_EXPORT_ALL_SYMBOLS=True
)

vcpkg_install_cmake()

# Rename exported target files into something vcpkg_fixup_cmake_targets expects
if(EXISTS ${CURRENT_PACKAGES_DIR}/lib/cmake/double-conversion)
    vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/double-conversion)
endif()

vcpkg_copy_pdbs()

# Include files should not be duplicated into the /debug/include directory.
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

# Handle copyright
file(COPY ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/double-conversion)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/double-conversion/LICENSE ${CURRENT_PACKAGES_DIR}/share/double-conversion/copyright)
