vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO zeux/meshoptimizer
    REF v0.14
    SHA512 303b3bf1bed7cba8f89bce1c2782e3718fc8f4ec01f7ffd64f5ca23406130097f07d234b142916b16fe586db97c7deaa0ae9135b4e558543cc1664e7db85de67
    HEAD_REF master
)

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "dynamic" BUILD_SHARED_LIBS)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DMESHOPT_BUILD_SHARED_LIBS=${BUILD_SHARED_LIBS}
)

vcpkg_install_cmake()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/meshoptimizer)

# Handle copyright
file(INSTALL ${SOURCE_PATH}/LICENSE.md
    DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT}
    RENAME copyright)

vcpkg_copy_pdbs()
