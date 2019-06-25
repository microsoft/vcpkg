include(vcpkg_common_functions)

if(VCPKG_CMAKE_SYSTEM_NAME STREQUAL "Darwin")
  set(VCPKG_POLICY_EMPTY_PACKAGE enabled)
  message(WARNING "You do not need this package on macOS, since you already have the Accelerate Framework")
  return()
endif()

vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_download_distfile(ARCHIVE
  URLS "http://www.netlib.org/clapack/clapack-3.2.1-CMAKE.tgz"
  FILENAME "clapack-3.2.1.tgz"
  SHA512 cf19c710291ddff3f6ead7d86bdfdeaebca21291d9df094bf0a8ef599546b007757fb2dbb19b56511bb53ef7456eac0c73973b9627bf4d02982c856124428b49
)

if(VCPKG_CMAKE_SYSTEM_NAME STREQUAL "Linux")
  set(ADDITIONAL_PATCH "enable_openblas_compat.patch")
endif()

vcpkg_extract_source_archive_ex(
  OUT_SOURCE_PATH SOURCE_PATH
  ARCHIVE ${ARCHIVE}
  PATCHES
      remove_internal_blas.patch
      ${ADDITIONAL_PATCH}
)

vcpkg_configure_cmake(
  SOURCE_PATH ${SOURCE_PATH}
  PREFER_NINJA
  OPTIONS
    -DCMAKE_DEBUG_POSTFIX=d
)

vcpkg_install_cmake()
vcpkg_copy_pdbs()

#TODO: fix the official exported targets, since they are broken (luckily it seems that no-one uses them for now)
vcpkg_fixup_cmake_targets()

#we install a cmake wrapper since the official FindLAPACK module in cmake does find clapack easily, unfortunately...
file(INSTALL ${CMAKE_CURRENT_LIST_DIR}/vcpkg-cmake-wrapper.cmake DESTINATION ${CURRENT_PACKAGES_DIR}/share/lapack)
file(INSTALL ${CMAKE_CURRENT_LIST_DIR}/FindLAPACK.cmake DESTINATION ${CURRENT_PACKAGES_DIR}/share/lapack)

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

# Handle copyright
file(INSTALL ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/clapack RENAME copyright)
