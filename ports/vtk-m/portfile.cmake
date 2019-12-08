include(vcpkg_common_functions)

vcpkg_check_features (OUT_FEATURE_OPTIONS OPTIONS 
    FEATURES
      cuda   VTKm_ENABLE_CUDA
      omp    VTKm_ENABLE_OPENMP
      tbb    VTKm_ENABLE_TBB
      mpi    VTKm_ENABLE_MPI
      double VTKm_USE_DOUBLE_PRECISION
    )
    
if   ("cuda" IN_LIST FEATURES AND NOT ENV{CUDACXX})
  set(ENV{CUDACXX} "$ENV{CUDA_PATH}/bin/nvcc")
  if(VCPKG_LIBRARY_LINKAGE STREQUAL "dynamic")
      message(STATUS "Feature CUDA forces static build!")
  endif()
  set(VCPKG_LIBRARY_LINKAGE "static") # CUDA forces static build.
endif()

list                     (APPEND OPTIONS -DVTKm_ENABLE_RENDERING=ON)
list                     (APPEND OPTIONS -DVTKm_ENABLE_DEVELOPER_FLAGS=OFF)
list                     (APPEND OPTIONS -DVTKm_ENABLE_CPACK=OFF)
list                     (APPEND OPTIONS -DBUILD_TESTING=OFF)

vcpkg_from_gitlab        (GITLAB_URL "https://gitlab.kitware.com" 
                          OUT_SOURCE_PATH SOURCE_PATH 
                          REPO vtk/vtk-m 
                          REF ae6999e534876ffa1b723511d60c2d8585a38f03 v1.3.0
                          SHA512 f53cdafcf31feada9eb597717c5196e73fe0c60d4b96ce522cb9a10fe2757ef3faacbda21e7257ebf6d4b64c4818ddbd41302686c6eba4393b78a1d0f44787cd)
vcpkg_configure_cmake    (SOURCE_PATH ${SOURCE_PATH} 
                          PREFER_NINJA 
                          OPTIONS ${OPTIONS})
vcpkg_install_cmake      ()
vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/vtkm-1.3 TARGET_PATH share/vtkm)

file(READ ${CURRENT_PACKAGES_DIR}/share/vtkm/VTKmConfig.cmake _contents)
string(REPLACE [[set_and_check(VTKm_CONFIG_DIR "${PACKAGE_PREFIX_DIR}/lib/cmake/vtkm-1.3")]] [[set_and_check(VTKm_CONFIG_DIR "${PACKAGE_PREFIX_DIR}/share/vtkm")]] _contents ${_contents})
file(WRITE ${CURRENT_PACKAGES_DIR}/share/vtkm/VTKmConfig.cmake ${_contents})

file                     (REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file                     (REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)

file                     (INSTALL ${SOURCE_PATH}/LICENSE.txt DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
