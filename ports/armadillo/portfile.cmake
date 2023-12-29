vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_sourceforge(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO arma
    FILENAME "armadillo-${VERSION}.tar.xz"
    SHA512 bf6a3db60256aa9789b52d92b33971a43816e73cd079d08e35350fcb251c213fba59604263595f886c4228147e75dd9308a5208ab9b290bb094128a1aee5da3d
    PATCHES
        cmake-config.patch
        dependencies.patch
        pkgconfig.patch
)

set(REQUIRES_PRIVATE "")
foreach(module IN ITEMS lapack blas)
    if(EXISTS "${CURRENT_INSTALLED_DIR}/lib/pkgconfig/${module}.pc")
        string(APPEND REQUIRES_PRIVATE " ${module}")
    endif()
endforeach()

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    DISABLE_PARALLEL_CONFIGURE
    OPTIONS
        -DALLOW_FLEXIBLAS_LINUX=OFF
        -DDETECT_HDF5=OFF
        "-DREQUIRES_PRIVATE=${REQUIRES_PRIVATE}"
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(PACKAGE_NAME Armadillo CONFIG_PATH share/Armadillo/CMake)
vcpkg_replace_string(   "${CURRENT_PACKAGES_DIR}/share/Armadillo/ArmadilloConfig.cmake"
                        [[include("${VCPKG_IMPORT_PREFIX}/share/Armadillo/ArmadilloLibraryDepends.cmake")]]
                        "include(CMakeFindDependencyMacro)\nfind_dependency(LAPACK)\ninclude(\"\${VCPKG_IMPORT_PREFIX}/share/Armadillo/ArmadilloLibraryDepends.cmake\")"
                    )
vcpkg_fixup_pkgconfig()
vcpkg_copy_pdbs()

file(REMOVE_RECURSE
    "${CURRENT_PACKAGES_DIR}/debug/include"
    "${CURRENT_PACKAGES_DIR}/debug/share"
    "${CURRENT_PACKAGES_DIR}/share/Armadillo/CMake"
)

file(GLOB SHARE_ARMADILLO_FILES "${CURRENT_PACKAGES_DIR}/share/Armadillo/*")
if(SHARE_ARMADILLO_FILES STREQUAL "")
    # On case sensitive file system there is an extra empty directory created that should be removed
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/share/Armadillo")
endif()

vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/include/armadillo_bits/config.hpp" "#define ARMA_AUX_LIBS " "#define ARMA_AUX_LIBS //")

file(COPY "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
file(COPY "${CMAKE_CURRENT_LIST_DIR}/vcpkg-cmake-wrapper.cmake" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE.txt")
