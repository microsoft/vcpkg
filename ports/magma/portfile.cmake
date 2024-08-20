
set(opts "")
if(VCPKG_TARGET_IS_WINDOWS AND VCPKG_LIBRARY_LINKAGE STREQUAL "dynamic")
  set(opts
    -DCMAKE_WINDOWS_EXPORT_ALL_SYMBOLS:BOOL=ON
    -DCMAKE_CUDA_SEPARABLE_COMPILATION:BOOL=OFF
  )
endif()

vcpkg_download_distfile(
    dist_file
    URLS https://icl.utk.edu/projectsfiles/magma/downloads/magma-${VERSION}.tar.gz
    FILENAME magma-${VERSION}.tar.gz
    SHA512 7ab52ad09f452f7b997da573f74465d5bc8c83392f724747b131a7015b1445c457defdb59ae7a2fd4930e2cdc5bce3c7b99a069f04db1752a5df36ddc6e84987
)

vcpkg_extract_source_archive(
    src_path
    ARCHIVE "${dist_file}"
    PATCHES 
      disable-openmp-msvc.patch
      no-tests.patch
      clang-cuda.patch
)

vcpkg_cmake_configure(
  SOURCE_PATH "${src_path}"
  OPTIONS
    -DMAGMA_ENABLE_CUDA=ON
    -DMAGMA_ENABLE_HIP=OFF # HIP is backend and seems additive?!
    -DUSE_FORTRAN=OFF
    ${opts}
)

vcpkg_cmake_install()

vcpkg_fixup_pkgconfig()

file(READ "${CURRENT_PACKAGES_DIR}/lib/pkgconfig/magma.pc" contents)
string(REGEX REPLACE "Cflags: [^\n]+" "Cflags: -I\${includedir}" contents "${contents}")
file(WRITE "${CURRENT_PACKAGES_DIR}/lib/pkgconfig/magma.pc" "${contents}")

if(NOT VCPKG_BUILD_TYPE)
  file(READ "${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig/magma.pc" contents)
  string(REGEX REPLACE "Cflags: [^\n]+" "Cflags: -I\${includedir}" contents "${contents}")
  file(WRITE "${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig/magma.pc" "${contents}")
endif()

file(REMOVE_RECURSE
  "${CURRENT_PACKAGES_DIR}/debug/include"
  "${CURRENT_PACKAGES_DIR}/debug/share"
)

vcpkg_install_copyright(FILE_LIST "${src_path}/COPYRIGHT")
