include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO google/double-conversion
    REF v3.0.0
    SHA512 5057af6e72f2aaace56ebdd9a0ddfa34318cbdfeabec5c361b60e6c92f160c8999c046c50f8c6f8d590eb8e97aa70bb6e97ba8148f0dc95dbc42f204fcdc1abf
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
file(RENAME ${CURRENT_PACKAGES_DIR}/debug/CMake/double-conversionLibraryDepends-debug.cmake
            ${CURRENT_PACKAGES_DIR}/debug/CMake/double-conversionTargets-debug.cmake)
file(RENAME ${CURRENT_PACKAGES_DIR}/CMake/double-conversionLibraryDepends-release.cmake
            ${CURRENT_PACKAGES_DIR}/CMake/double-conversionTargets-release.cmake)
file(RENAME ${CURRENT_PACKAGES_DIR}/CMake/double-conversionLibraryDepends.cmake
            ${CURRENT_PACKAGES_DIR}/CMake/double-conversionTargets.cmake)

file(READ ${CURRENT_PACKAGES_DIR}/CMake/double-conversionTargets.cmake TARGETS_FILE)
string(REPLACE "double-conversionLibraryDepends" "double-conversionTargets" TARGETS_FILE "${TARGETS_FILE}")
file(WRITE ${CURRENT_PACKAGES_DIR}/CMake/double-conversionTargets.cmake "${TARGETS_FILE}")

# Remove hardcoded paths from config file
file(READ ${CURRENT_PACKAGES_DIR}/CMake/double-conversionConfig.cmake CONFIG_FILE)
string(REPLACE "${CURRENT_PACKAGES_DIR}/lib/cmake/double-conversion/double-conversionLibraryDepends.cmake"
               "\${double-conversion_CMAKE_DIR}/double-conversionTargets.cmake" CONFIG_FILE "${CONFIG_FILE}")
string(REPLACE "${CURRENT_PACKAGES_DIR}"
               "\${double-conversion_CMAKE_DIR}/../.." CONFIG_FILE "${CONFIG_FILE}")
file(WRITE ${CURRENT_PACKAGES_DIR}/CMake/double-conversionConfig.cmake "${CONFIG_FILE}")

vcpkg_fixup_cmake_targets(CONFIG_PATH CMake)

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)

vcpkg_copy_pdbs()

# Include files should not be duplicated into the /debug/include directory.
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

# Handle copyright
file(COPY ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/double-conversion)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/double-conversion/LICENSE ${CURRENT_PACKAGES_DIR}/share/double-conversion/copyright)
