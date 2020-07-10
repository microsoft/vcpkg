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
                  REF f2aa6ad5be1a97e3fb41ef4680ee2c76c3434ac0 # v1.5.0 Version is strongly locked to VTK 9.0. Upgrading will most likly brake the VTK build
                  SHA512 2f2a273f74d9a583df9e25a4792440d8d89652fa14b3153f2ea5afbd329b50970e7b9bd68e0ccd036baf5c1f3ad7a8302d95c01dbb30d9a46c045987eebf5370)
                  # For people only wanting vtk-m and not VTK 
                  #REF 74ffad9bd0679d061bc87e544a728f1c3c926269 # v1.5.1
                  #SHA512 c9e1c18432b6c11ae086445255acf9477fe4c888122a2b2a9713dc63a40d2e4c2375742157526b5f0869f14c62a4ad66d81ee58d6cc75a1d53a1d615525a03c9)
vcpkg_configure_cmake(SOURCE_PATH ${SOURCE_PATH} 
                      PREFER_NINJA 
                      OPTIONS ${OPTIONS})
vcpkg_install_cmake()
vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/vtkm-1.5 TARGET_PATH share/vtkm)

file(READ ${CURRENT_PACKAGES_DIR}/share/vtkm/VTKmConfig.cmake _contents)
string(REPLACE [[set_and_check(VTKm_CONFIG_DIR "${PACKAGE_PREFIX_DIR}/lib/cmake/vtkm-1.5")]] [[set_and_check(VTKm_CONFIG_DIR "${PACKAGE_PREFIX_DIR}/share/vtkm")]] _contents ${_contents})
file(WRITE ${CURRENT_PACKAGES_DIR}/share/vtkm/VTKmConfig.cmake ${_contents})

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)

file(INSTALL ${SOURCE_PATH}/LICENSE.txt DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
