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
    
if("cuda" IN_LIST FEATURES AND NOT ENV{CUDACXX})
  set(ENV{CUDACXX} "$ENV{CUDA_PATH}/bin/nvcc")
  if(VCPKG_LIBRARY_LINKAGE STREQUAL "dynamic")
      message(STATUS "Feature CUDA forces static build!")
  endif()
  set(VCPKG_LIBRARY_LINKAGE "static") # CUDA forces static build.
endif()

list(APPEND OPTIONS 
  -DVTKm_ENABLE_RENDERING=ON
  -DVTKm_ENABLE_DEVELOPER_FLAGS=OFF
  -DVTKm_ENABLE_CPACK=OFF
  -DVTKm_ENABLE_EXAMPLES=OFF
  -DVTKm_ENABLE_TUTORIALS=OFF
  -DVTKm_ENABLE_DOCUMENTATION=OFF
  -DVTKm_ENABLE_BENCHMARKS=OFF
  -DVTKm_USE_DEFAULT_TYPES_FOR_VTK=ON
  -DBUILD_TESTING=OFF
  -DVTKm_ENABLE_TESTING=OFF
  -DVTKm_USE_64BIT_IDS=ON
  -DVTKm_ENABLE_HDF5_IO=OFF
  -DVTKm_NO_INSTALL_README_LICENSE=ON
  -DVTKm_ENABLE_GPU_MPI=OFF
  )
# For port customizations on unix systems. 
# Please feel free to make these port features if it makes any sense
#list(APPEND OPTIONS -DVTKm_ENABLE_GL_CONTEXT=ON) # or
#list(APPEND OPTIONS -DVTKm_ENABLE_EGL_CONTEXT=ON) # or
#list(APPEND OPTIONS -DVTKm_ENABLE_OSMESA_CONTEXT=ON)
list(APPEND OPTIONS -DBUILD_TESTING=OFF)

vcpkg_from_gitlab(GITLAB_URL "https://gitlab.kitware.com" 
    OUT_SOURCE_PATH SOURCE_PATH 
    REPO vtk/vtk-m 
    REF a057f62e756efc43095e72c5813aaaf2dea36ebb # v2.1.0 Upgrading will most likely break the VTK build
    SHA512 fa08bd597e1918d10e7fed9f6b9667fd53f4a14589580e68691aad3cfb240f7de80fa0c5001712f100911c2262b5af3105b8f21da21b945a88e1204ea82b92a6
    PATCHES
        omp.patch
        fix-build.patch
        fix-macos-15-6.patch
        vtkm-macos-fix-pr-3272.patch
        vtkm-macos-fix-commit-48e385af319543800398656645327243a29babfb.patch
)

vcpkg_cmake_configure(
  SOURCE_PATH "${SOURCE_PATH}"
  OPTIONS ${OPTIONS}
)
vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH "lib/cmake/vtkm-2.1" PACKAGE_NAME vtkm)

vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/share/vtkm/VTKmConfig.cmake" 
                    [[set_and_check(VTKm_CONFIG_DIR "${PACKAGE_PREFIX_DIR}/lib/cmake/vtkm-2.1")]]
                    [[set_and_check(VTKm_CONFIG_DIR "${PACKAGE_PREFIX_DIR}/share/vtkm")]])
vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/share/vtkm/VTKmConfig.cmake" "${CURRENT_BUILDTREES_DIR}" "not/existing/buildtree")

file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/lib/pkgconfig")
file(RENAME "${CURRENT_PACKAGES_DIR}/share/vtkm-2.1/vtkm.pc" "${CURRENT_PACKAGES_DIR}/lib/pkgconfig/vtkm.pc")
if(NOT VCPKG_BUILD_TYPE)
  file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig")
  file(RENAME "${CURRENT_PACKAGES_DIR}/debug/share/vtkm-2.1/vtkm.pc" "${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig/vtkm.pc")
endif()
vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

file(INSTALL "${SOURCE_PATH}/LICENSE.txt" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
