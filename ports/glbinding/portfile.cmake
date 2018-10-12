include(vcpkg_common_functions)
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO cginternals/glbinding
    REF v3.0.2
    SHA512 524ad20a11af7d8ee1764f53326b43efb3b3dbd6c64d1539f4d9fa2bcb7b58a6bd6caf460d6944aed4fd7439b82536d8f28a0f0f51c14c62c2f0c73baab9afcb
    HEAD_REF master
    PATCHES force-system-install.patch
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    OPTIONS
        -DOPTION_BUILD_TESTS=OFF
        -DOPTION_BUILD_GPU_TESTS=OFF
        -DOPTION_BUILD_TOOLS=OFF
        -DGIT_REV=0
        -DCMAKE_DISABLE_FIND_PACKAGE_cpplocate=ON
)

vcpkg_install_cmake()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

vcpkg_fixup_cmake_targets(CONFIG_PATH share/glbinding/cmake/glbinding TARGET_PATH share/glbinding/cmake/glbinding)
vcpkg_fixup_cmake_targets(CONFIG_PATH share/glbinding/cmake/glbinding-aux TARGET_PATH share/glbinding/cmake/glbinding-aux)

file(WRITE ${CURRENT_PACKAGES_DIR}/share/glbinding/glbinding-config.cmake "include(\${CMAKE_CURRENT_LIST_DIR}/cmake/glbinding/glbinding-export.cmake)\ninclude(\${CMAKE_CURRENT_LIST_DIR}/cmake/glbinding-aux/glbinding-aux-export.cmake)\nset(glbinding_FOUND TRUE)\n")
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)

# Handle copyright
file(RENAME ${CURRENT_PACKAGES_DIR}/share/glbinding/LICENSE ${CURRENT_PACKAGES_DIR}/share/glbinding/copyright)

vcpkg_copy_pdbs()
