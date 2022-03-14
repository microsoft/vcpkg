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
    )
    
if("cuda" IN_LIST FEATURES AND NOT ENV{CUDACXX})
  set(ENV{CUDACXX} "$ENV{CUDA_PATH}/bin/nvcc")
  if(VCPKG_LIBRARY_LINKAGE STREQUAL "dynamic")
      message(STATUS "Feature CUDA forces static build!")
  endif()
  set(VCPKG_LIBRARY_LINKAGE "static") # CUDA forces static build.
endif()

list(APPEND OPTIONS -DVTKm_ENABLE_RENDERING=ON)
list(APPEND OPTIONS -DVTKm_ENABLE_DEVELOPER_FLAGS=OFF)
list(APPEND OPTIONS -DVTKm_ENABLE_CPACK=OFF)
list(APPEND OPTIONS -DVTKm_USE_DEFAULT_TYPES_FOR_VTK=ON)
# For port customizations on unix systems. 
# Please feel free to make these port features if it makes any sense
#list(APPEND OPTIONS -DVTKm_ENABLE_GL_CONTEXT=ON) # or
#list(APPEND OPTIONS -DVTKm_ENABLE_EGL_CONTEXT=ON) # or
#list(APPEND OPTIONS -DVTKm_ENABLE_OSMESA_CONTEXT=ON)
list(APPEND OPTIONS -DBUILD_TESTING=OFF)

vcpkg_from_gitlab(GITLAB_URL "https://gitlab.kitware.com" 
                  OUT_SOURCE_PATH SOURCE_PATH 
                  REPO vtk/vtk-m 
                  REF 13a117e0e8935eef3f320b5a1cd71d9911ad9853 # v1.6.0 Version is strongly locked to VTK 9.0. Upgrading will most likly brake the VTK build
                  SHA512 54f7f52ab4ee7954b6a303ffd3b8bcb18105b5d2fd8ed54b4e487fce2ebfbc51507e632189f775c79eea22ad24bd56bca401ddd679fc03d787342dd33d2ba18b
                  FILE_DISAMBIGUATOR 1)
vcpkg_cmake_configure(
  SOURCE_PATH "${SOURCE_PATH}"
  OPTIONS ${OPTIONS}
)
vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/vtkm-1.6 PACKAGE_NAME vtkm)

vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/share/vtkm/VTKmConfig.cmake" [[set_and_check(VTKm_CONFIG_DIR "${PACKAGE_PREFIX_DIR}/lib/cmake/vtkm-1.6")]] [[set_and_check(VTKm_CONFIG_DIR "${PACKAGE_PREFIX_DIR}/share/vtkm")]])
vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/share/vtkm/VTKmConfig.cmake" "${CURRENT_BUILDTREES_DIR}" "not/existing/buildtree")

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

file(INSTALL "${SOURCE_PATH}/LICENSE.txt" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
