vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO cginternals/globjects
    REF dc68b09a53ec20683d3b3a12ed8d9cb12602bb9a
    SHA512 5145df795a73a8d74e983e143fd57441865f3082860efb89a3aa8c4d64c2eb6f0256a8049ccd5479dd77e53ef6638d9c903b29a8ef2b41a076003d9595912500
    HEAD_REF master
    PATCHES
        system-install.patch
        fix-dependency-glm.patch
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

vcpkg_fixup_cmake_targets(CONFIG_PATH share/globjects/cmake/globjects)

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include ${CURRENT_PACKAGES_DIR}/debug/share)

file(WRITE ${CURRENT_PACKAGES_DIR}/share/globjects/globjects-config.cmake "include(CMakeFindDependencyMacro)
find_dependency(glm)
find_dependency(glbinding)

include(\${CMAKE_CURRENT_LIST_DIR}/globjects-export.cmake)
")

# Handle copyright
file(RENAME ${CURRENT_PACKAGES_DIR}/share/globjects/LICENSE ${CURRENT_PACKAGES_DIR}/share/globjects/copyright)

vcpkg_copy_pdbs()
