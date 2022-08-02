if(EXISTS "${CURRENT_INSTALLED_DIR}/share/lapack-reference/copyright")
    message(FATAL_ERROR "Can't build ${PORT} if lapack-reference is installed. Please remove lapack-reference:${TARGET_TRIPLET}, and try to install ${PORT}:${TARGET_TRIPLET} again.")
endif()

vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_download_distfile(ARCHIVE
  URLS "https://www.netlib.org/clapack/clapack-3.2.1-CMAKE.tgz"
  FILENAME "clapack-3.2.1.tgz"
  SHA512 cf19c710291ddff3f6ead7d86bdfdeaebca21291d9df094bf0a8ef599546b007757fb2dbb19b56511bb53ef7456eac0c73973b9627bf4d02982c856124428b49
)

vcpkg_extract_source_archive_ex(
  OUT_SOURCE_PATH SOURCE_PATH
  ARCHIVE ${ARCHIVE}
  PATCHES
      remove_internal_blas.patch
      fix-ConfigFile.patch
      fix-install.patch
      support-uwp.patch
)

set(ARITH_PATH)
if(DEFINED CLAPACK_ARITH_PATH)
  set(ARITH_PATH "-DARITH_PATH=${CLAPACK_ARITH_PATH}")
elseif(NOT TARGET_TRIPLET STREQUAL HOST_TRIPLET)
  if(VCPKG_TARGET_IS_WINDOWS OR VCPKG_TARGET_IS_UWP)
    if(VCPKG_TARGET_ARCHITECTURE MATCHES "^x64$|^arm64$")
      set(ARITH_PATH "-DARITH_PATH=${CMAKE_CURRENT_LIST_DIR}/arith_win64.h")
    else()
      set(ARITH_PATH "-DARITH_PATH=${CMAKE_CURRENT_LIST_DIR}/arith_win32.h")
    endif()
  elseif(VCPKG_TARGET_IS_OSX OR VCPKG_TARGET_IS_IOS)
    set(ARITH_PATH "-DARITH_PATH=${CMAKE_CURRENT_LIST_DIR}/arith_osx.h")
  elseif(VCPKG_TARGET_IS_LINUX AND VCPKG_TARGET_ARCHITECTURE STREQUAL "x64")
    set(ARITH_PATH "-DARITH_PATH=${CMAKE_CURRENT_LIST_DIR}/arith_linux64.h")
  else()
    message(WARNING
"Unable to cross-compile clapack for ${VCPKG_TARGET_ARCHITECTURE}-${VCPKG_CMAKE_SYSTEM_NAME}.
No arith.h is available and arithchk must be executed for the target.
To fix this issue, define CLAPACK_ARITH_PATH in your triplet to the location of a pre-generated arith.h file.

Continuing with trying to run arithchk anyway.")
  endif()
endif()

vcpkg_configure_cmake(
  SOURCE_PATH ${SOURCE_PATH}
  PREFER_NINJA
  OPTIONS
    -DCMAKE_DEBUG_POSTFIX=d
    ${ARITH_PATH}
)

vcpkg_install_cmake()
vcpkg_copy_pdbs()

#TODO: fix the official exported targets, since they are broken (luckily it seems that no-one uses them for now)
vcpkg_fixup_cmake_targets(CONFIG_PATH share/clapack)

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

# Install clapack wrappers.
file(INSTALL ${CMAKE_CURRENT_LIST_DIR}/vcpkg-cmake-wrapper.cmake DESTINATION ${CURRENT_PACKAGES_DIR}/share/lapack)
file(INSTALL ${CMAKE_CURRENT_LIST_DIR}/FindLAPACK.cmake DESTINATION ${CURRENT_PACKAGES_DIR}/share/lapack)
# Handle copyright
file(INSTALL ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
