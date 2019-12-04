include(vcpkg_common_functions)

vcpkg_check_features (OUT_FEATURE_OPTIONS OPTIONS FEATURES
  cuda VTKm_ENABLE_CUDA
  omp  VTKm_ENABLE_OPENMP
  tbb  VTKm_ENABLE_TBB
  mpi  VTKm_ENABLE_MPI
)
if   ("cuda" IN_LIST FEATURES AND NOT ENV{CUDACXX})
  set(ENV{CUDACXX} "$ENV{CUDA_PATH}/bin/nvcc")
  set(BUILD_SHARED_LIBS OFF) # CUDA forces static build.
endif()

list                     (APPEND OPTIONS -DVTKm_ENABLE_RENDERING=OFF)
vcpkg_from_gitlab        (GITLAB_URL "https://gitlab.kitware.com" OUT_SOURCE_PATH SOURCE_PATH REPO vtk/vtk-m REF v1.5.0 SHA512 c75c224ce86fee694b37a841befe5b4917d7c9dfeb47c3c899632cb81b772bc3178867c45668168a5377ad3b971c4e20da798130e36f67ab957e494582f94f9a)
vcpkg_configure_cmake    (SOURCE_PATH ${SOURCE_PATH} PREFER_NINJA OPTIONS ${OPTIONS})
vcpkg_install_cmake      ()
vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/vtkm-1.5)
file                     (REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file                     (REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)
file                     (INSTALL ${SOURCE_PATH}/LICENSE.txt DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
