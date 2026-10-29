vcpkg_download_distfile(GLBINDING_COMPAT_PATCH
    URLS "https://github.com/cginternals/globjects/commit/ad785032be8764fa9201757db1f3cec4e693ecc9.diff?full_index=1"
    FILENAME "globjects-ad785032be8764fa9201757db1f3cec4e693ecc9-glbinding-compat.diff"
    SHA512 da55a41fa4491d7a5ab2b0ed085cb128de9b877df0ef032558f448b4f1bb76f06f5cc666349fb2959434e58df0c375adc44db9ddde4b685d351fa4101aeaa020
)

vcpkg_download_distfile(ENUM_COMPAT_PATCH
    URLS "https://github.com/cginternals/globjects/commit/2e2e4941fafaf01cd19466a79e9fe292318eb64a.diff?full_index=1"
    FILENAME "globjects-2e2e4941fafaf01cd19466a79e9fe292318eb64a-enum-compat.diff"
    SHA512 a8b7f8fbedcaa972f6574c7e374e9f6e9ba8777b1c94954796aa172f67951866f085962ac0f11c6a5189f84b7dcafd6959c3d16017ea5f8fc237ac83b490f4f3
)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO cginternals/globjects
    REF dc68b09a53ec20683d3b3a12ed8d9cb12602bb9a
    SHA512 5145df795a73a8d74e983e143fd57441865f3082860efb89a3aa8c4d64c2eb6f0256a8049ccd5479dd77e53ef6638d9c903b29a8ef2b41a076003d9595912500
    HEAD_REF master
    PATCHES
        system-install.patch
        fix-dependency-glm.patch
        "${GLBINDING_COMPAT_PATCH}"
        "${ENUM_COMPAT_PATCH}"
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DOPTION_BUILD_TESTS=OFF
        -DOPTION_BUILD_GPU_TESTS=OFF
        -DGIT_REV=0
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(CONFIG_PATH share/globjects/cmake/globjects)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include" "${CURRENT_PACKAGES_DIR}/debug/share")

file(WRITE "${CURRENT_PACKAGES_DIR}/share/globjects/globjects-config.cmake" "include(CMakeFindDependencyMacro)
find_dependency(glm)
find_dependency(glbinding)

include(\${CMAKE_CURRENT_LIST_DIR}/globjects-export.cmake)
")

# Handle copyright
file(RENAME "${CURRENT_PACKAGES_DIR}/share/${PORT}/LICENSE" "${CURRENT_PACKAGES_DIR}/share/${PORT}/copyright")

vcpkg_copy_pdbs()
