include(vcpkg_common_functions)
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO zeux/meshoptimizer
    REF v0.14
    SHA512 303b3bf1bed7cba8f89bce1c2782e3718fc8f4ec01f7ffd64f5ca23406130097f07d234b142916b16fe586db97c7deaa0ae9135b4e558543cc1664e7db85de67
    HEAD_REF master
)

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "dynamic" BUILD_SHADERED_LIBS)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA # Disable this option if project cannot be built with Ninja
    OPTIONS
        -DMESHOPT_BUILD_SHARED_LIBS=${BUILD_SHADERED_LIBS}
)

vcpkg_install_cmake()

# Debug includes and share are the same as release
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)

# Merge /debug/lib/cmake and /lib/cmake into /share/meshoptimizer
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/lib/cmake)
file(INSTALL
        ${CURRENT_PACKAGES_DIR}/lib/cmake/meshoptimizer/meshoptimizerConfig.cmake
        ${CURRENT_PACKAGES_DIR}/lib/cmake/meshoptimizer/meshoptimizerConfigVersion.cmake
    DESTINATION ${CURRENT_PACKAGES_DIR}/share/meshoptimizer)
# Make sure no empty folder is left behind
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/lib/cmake)

# Handle copyright
file(INSTALL ${SOURCE_PATH}/LICENSE.md
    DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT}
    RENAME copyright)

vcpkg_copy_pdbs()
