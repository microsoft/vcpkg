include(vcpkg_common_functions)

vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_download_distfile(ARCHIVE
  URLS "http://www.netlib.org/clapack/clapack-3.2.1-CMAKE.tgz"
  FILENAME "clapack-3.2.1.tgz"
  SHA512 cf19c710291ddff3f6ead7d86bdfdeaebca21291d9df094bf0a8ef599546b007757fb2dbb19b56511bb53ef7456eac0c73973b9627bf4d02982c856124428b49
)

vcpkg_extract_source_archive_ex(
  OUT_SOURCE_PATH SOURCE_PATH
  ARCHIVE ${ARCHIVE}
  PATCHES
      remove_internal_blas.patch
)

vcpkg_configure_cmake(
  SOURCE_PATH ${SOURCE_PATH}
  PREFER_NINJA
  OPTIONS
    -DCMAKE_DEBUG_POSTFIX=d
)

vcpkg_install_cmake()
vcpkg_copy_pdbs()

#TODO: fix the exported targets, since they are broken.
vcpkg_fixup_cmake_targets(CONFIG_PATH share/clapack)

#we install a cmake wrapper since the official FindLAPACK module does not accept clapack as a valid library, unfortunately...
file(INSTALL ${CMAKE_CURRENT_LIST_DIR}/vcpkg-cmake-wrapper.cmake DESTINATION ${CURRENT_PACKAGES_DIR}/share/lapack)

#we also intercept any call to FindCLAPACK redirecting it to our FindLAPACK
file(INSTALL ${CMAKE_CURRENT_LIST_DIR}/vcpkg-cmake-wrapper-clapack.cmake DESTINATION ${CURRENT_PACKAGES_DIR}/share/clapack RENAME vcpkg-cmake-wrapper.cmake)

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

# Handle copyright
file(INSTALL ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/clapack RENAME copyright)
