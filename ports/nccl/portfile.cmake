vcpkg_from_github(
    OUT_SOURCE_PATH src_path
    REPO NVIDIA/nccl
    REF v${VERSION}-1
    SHA512 25226874007b02c0195a5715460694ada1f8a9c841ee1b49c41b6c39865e5e7f28da9a43bb06507d541320fc9be919cc09931c8026eabdff6385915c6bf95a7f
    PATCHES
      cppflags.patch
)

# Note: Feel free to add arm64 support -> see conda-forge/nccl-feedstock

set(ENV{CUDA_HOME} "${CURRENT_INSTALLED_DIR}/tools/cuda")

#Trick to avoid calling numerous calls to z_vcpkg_get_cmake_vars and deleting the buildtree
z_vcpkg_get_cmake_vars(cmake_vars_file)
include("${cmake_vars_file}")
set(Z_VCPKG_GET_CMAKE_VARS_FILE "${cmake_vars_file}" CACHE STRING "" FORCE)
set(Z_VCPKG_GET_CMAKE_VARS_FILE_debug "${cmake_vars_file}" CACHE STRING "" FORCE)
set(Z_VCPKG_GET_CMAKE_VARS_FILE_release "${cmake_vars_file}" CACHE STRING "" FORCE)

file(COPY "${src_path}/" DESTINATION "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel")
if(NOT VCPKG_BUILD_TYPE)
  file(COPY "${src_path}/" DESTINATION "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg")
endif()

# Trick to install with an additional OPTION
if(NOT VCPKG_BUILD_TYPE)
  set(VCPKG_BUILD_TYPE debug)
  vcpkg_build_make(BUILD_TARGET src.lib)
  vcpkg_build_make(BUILD_TARGET install OPTIONS "PREFIX=${CURRENT_PACKAGES_DIR}/debug" LOGFILE_ROOT install)
endif()
set(VCPKG_BUILD_TYPE release)
vcpkg_build_make(BUILD_TARGET src.lib)
vcpkg_build_make(BUILD_TARGET install OPTIONS "PREFIX=${CURRENT_PACKAGES_DIR}" LOGFILE_ROOT install)

file(INSTALL "${CURRENT_PORT_DIR}/FindNCCL.cmake" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
configure_file("${CURRENT_PORT_DIR}/vcpkg-cmake-wrapper.cmake" "${CURRENT_PACKAGES_DIR}/share/${PORT}/vcpkg-cmake-wrapper.cmake" @ONLY)
file(INSTALL "${CURRENT_PORT_DIR}/usage" DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT})

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_fixup_pkgconfig()

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
  file(GLOB_RECURSE to_delete "${CURRENT_PACKAGES_DIR}/**/*.so*")
  file(RENAME "${CURRENT_PACKAGES_DIR}/lib/libnccl_static.a" "${CURRENT_PACKAGES_DIR}/lib/libnccl.a")
  if(NOT VCPKG_BUILD_TYPE)
    file(RENAME "${CURRENT_PACKAGES_DIR}/debug/lib/libnccl_static.a" "${CURRENT_PACKAGES_DIR}/debug/lib/libnccl.a")
  endif()
else()
  file(GLOB_RECURSE to_delete "${CURRENT_PACKAGES_DIR}/**/*.a")
endif()
file(REMOVE ${to_delete})

vcpkg_install_copyright(FILE_LIST "${src_path}/LICENSE.txt")
