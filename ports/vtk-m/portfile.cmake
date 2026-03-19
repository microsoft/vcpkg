# VENDORED DEPENDENCIES! 
# TODO: Should be replaced in the future with VCPKG internal versions
# add_subdirectory(thirdparty/diy)
# add_subdirectory(thirdparty/lodepng)
# if(VTKm_ENABLE_LOGGING)
  # add_subdirectory(thirdparty/loguru)
# endif()
# add_subdirectory(thirdparty/optionparser)
# add_subdirectory(thirdparty/taotuple)
# add_subdirectory(thirdparty/lcl)

vcpkg_check_features (OUT_FEATURE_OPTIONS OPTIONS 
    FEATURES
      cuda   VTKm_ENABLE_CUDA
      omp    VTKm_ENABLE_OPENMP
      tbb    VTKm_ENABLE_TBB
      mpi    VTKm_ENABLE_MPI
      double VTKm_USE_DOUBLE_PRECISION
      kokkos VTKm_ENABLE_KOKKOS # No port yet
    )
    
if("cuda" IN_LIST FEATURES)
    vcpkg_find_cuda(OUT_CUDA_TOOLKIT_ROOT cuda_toolkit_root)
    list(APPEND OPTIONS
        "-DCMAKE_CUDA_COMPILER=${NVCC}"
        -DCMAKE_CUDA_ARCHITECTURES=all-major # override with VCPKG_CMAKE_CONFIGURE_OPTIONS
    )
    if(VCPKG_LIBRARY_LINKAGE STREQUAL "dynamic")
        message(STATUS "Feature CUDA forces static build!")
    endif()
    set(VCPKG_LIBRARY_LINKAGE "static") # CUDA forces static build.
endif()

# For port customizations on unix systems. 
# Please feel free to make these port features if it makes any sense
#list(APPEND OPTIONS -DVTKm_ENABLE_GL_CONTEXT=ON) # or
#list(APPEND OPTIONS -DVTKm_ENABLE_EGL_CONTEXT=ON) # or
#list(APPEND OPTIONS -DVTKm_ENABLE_OSMESA_CONTEXT=ON)

vcpkg_from_gitlab(GITLAB_URL "https://gitlab.kitware.com" 
    OUT_SOURCE_PATH SOURCE_PATH 
    REPO vtk/vtk-m 
    REF v${VERSION}
    SHA512 eee8245f8ec4a960dfb55e4372fb4c63b6fcafcea33d23cec5f6ac411e531ac3bd2cd830bffeb9b2d44ad94e67bee560952734ab55390cb9a8b690037e380f91
    PATCHES
        fix-macos-15-6.patch
        pkgconfig.diff
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        ${OPTIONS}
        -DBUILD_TESTING=OFF
        -DVTKm_ENABLE_BENCHMARKS=OFF
        -DVTKm_ENABLE_CPACK=OFF
        -DVTKm_ENABLE_DEVELOPER_FLAGS=OFF
        -DVTKm_ENABLE_DOCUMENTATION=OFF
        -DVTKm_ENABLE_EXAMPLES=OFF
        -DVTKm_ENABLE_GPU_MPI=OFF
        -DVTKm_ENABLE_HDF5_IO=OFF
        -DVTKm_ENABLE_RENDERING=ON
        -DVTKm_ENABLE_TESTING=OFF
        -DVTKm_ENABLE_TUTORIALS=OFF
        -DVTKm_NO_INSTALL_README_LICENSE=ON
        -DVTKm_USE_64BIT_IDS=ON
        -DVTKm_USE_DEFAULT_TYPES_FOR_VTK=ON
)
vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH "lib/cmake/vtkm-2.3" PACKAGE_NAME vtkm-2.3)
vcpkg_fixup_pkgconfig()

vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/share/vtkm-2.3/VTKmConfig.cmake" "${CURRENT_BUILDTREES_DIR}" ":not/existing/buildtree:")
vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/share/vtkm-2.3/VTKmConfig.cmake" [[/lib/cmake/vtkm-2.3"]] [[/share/vtkm-2.3"]])

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE.txt")
