include(vcpkg_common_functions)

if(NOT VCPKG_TARGET_ARCHITECTURE STREQUAL "x64")
    message(FATAL_ERROR "openblas can only be built for x64 currently")
endif()

set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/clapack-3.2.1-CMAKE)
vcpkg_download_distfile(ARCHIVE
    URLS "http://www.netlib.org/clapack/clapack-3.2.1-CMAKE.tgz"
    FILENAME "clapack-3.2.1.tgz"
    SHA512 cf19c710291ddff3f6ead7d86bdfdeaebca21291d9df094bf0a8ef599546b007757fb2dbb19b56511bb53ef7456eac0c73973b9627bf4d02982c856124428b49
)

vcpkg_extract_source_archive_ex(
  OUT_SOURCE_PATH SOURCE_PATH
  ARCHIVE ${ARCHIVE}
  PATCHES
    use-other-blas-and-install-include.patch
    link-to-math-lib.patch
)

if(VCPKG_CMAKE_SYSTEM_NAME STREQUAL "Linux")
    vcpkg_apply_patches(
        SOURCE_PATH ${SOURCE_PATH}
        PATCHES "${CMAKE_CURRENT_LIST_DIR}/fix-linux-build.patch"
    )
endif()

if(NOT VCPKG_CMAKE_SYSTEM_NAME)
    file(COPY ${CMAKE_CURRENT_LIST_DIR}/lapack.def DESTINATION ${SOURCE_PATH}/SRC)
endif()

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
)

vcpkg_install_cmake()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

# Handle copyright
file(COPY ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/clapack)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/clapack/COPYING ${CURRENT_PACKAGES_DIR}/share/clapack/copyright)

vcpkg_copy_pdbs()
