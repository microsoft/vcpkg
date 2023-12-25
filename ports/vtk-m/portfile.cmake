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
                  REF 902fdac6fafb6358ce88f8747d55e2c0715241f1 # v1.9.0 Upgrading will most likly brake the VTK build
                  SHA512 f83872495ed3dbcea372776c4439a7d224568d144ff602c188fae120026778b1bee681c9e9535cc693e870cbc08ca9896af2bc954935c289f6b9a24f2471a50b
                  FILE_DISAMBIGUATOR 1
                  PATCHES
                    omp.patch
)
vcpkg_cmake_configure(
  SOURCE_PATH "${SOURCE_PATH}"
  OPTIONS ${OPTIONS}
)
vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH "lib/cmake/vtkm-1.9" PACKAGE_NAME vtkm)

vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/share/vtkm/VTKmConfig.cmake" 
                    [[set_and_check(VTKm_CONFIG_DIR "${PACKAGE_PREFIX_DIR}/lib/cmake/vtkm-1.9")]]
                    [[set_and_check(VTKm_CONFIG_DIR "${PACKAGE_PREFIX_DIR}/share/vtkm")]])
vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/share/vtkm/VTKmConfig.cmake" "${CURRENT_BUILDTREES_DIR}" "not/existing/buildtree")

file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/lib/pkgconfig")
file(RENAME "${CURRENT_PACKAGES_DIR}/share/vtkm-1.9/vtkm.pc" "${CURRENT_PACKAGES_DIR}/lib/pkgconfig/vtkm.pc")
if(NOT VCPKG_BUILD_TYPE)
  file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig")
  file(RENAME "${CURRENT_PACKAGES_DIR}/debug/share/vtkm-1.9/vtkm.pc" "${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig/vtkm.pc")
endif()
vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

file(INSTALL "${SOURCE_PATH}/LICENSE.txt" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
