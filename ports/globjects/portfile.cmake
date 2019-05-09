include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO cginternals/globjects
    REF fe53c4a386506d3374df12ad6f1f67c4232aa389
    SHA512 62b40675671acf050bfe4836da5b6b6a757185d296a86ad1079cf79e4a149820971ed46fce7379b73707dff368919b63d52044230a7ce75601441fe368d91e63
    HEAD_REF master
    PATCHES system-install.patch
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DOPTION_BUILD_TESTS=OFF
        -DOPTION_BUILD_GPU_TESTS=OFF
        -DGIT_REV=0
)

vcpkg_install_cmake()

vcpkg_fixup_cmake_targets(CONFIG_PATH share/globjects/cmake/globjects TARGET_PATH share/globjects/cmake/globjects)

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include ${CURRENT_PACKAGES_DIR}/debug/share)

file(WRITE ${CURRENT_PACKAGES_DIR}/share/globjects/globjects-config.cmake "include(CMakeFindDependencyMacro)
find_dependency(glm)
find_dependency(glbinding)

include(\${CMAKE_CURRENT_LIST_DIR}/cmake/globjects/globjects-export.cmake)
")

# Handle copyright
file(RENAME ${CURRENT_PACKAGES_DIR}/share/globjects/LICENSE ${CURRENT_PACKAGES_DIR}/share/globjects/copyright)

vcpkg_copy_pdbs()
