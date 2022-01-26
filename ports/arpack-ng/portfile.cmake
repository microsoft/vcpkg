#TODO: Features to add:
# USE_XBLAS??? extended precision blas. needs xblas
# LAPACKE should be its own PORT
# USE_OPTIMIZED_LAPACK (Probably not what we want. Does a find_package(LAPACK): probably for LAPACKE only builds _> own port?)
# LAPACKE Builds LAPACKE
# LAPACKE_WITH_TMG Build LAPACKE with tmglib routines
include(vcpkg_find_fortran)
SET(VCPKG_POLICY_EMPTY_INCLUDE_FOLDER enabled)

set(arpack_ver 3.8.0)

vcpkg_from_github(
  OUT_SOURCE_PATH SOURCE_PATH
  REPO  "opencollab/arpack-ng"
  REF "${arpack_ver}"
  SHA512 "8969c74c4c0459ea2d29ea49d5260f668fd33f73886df0da78a42a94aea93c9f5fb70f5df035266db68807ab09a92c13487a7a4e6ca64922145aade8a148a2de"
  HEAD_REF master
  PATCHES "arpack-msc.patch" # Patch for support for MSVC compiler
)

if(NOT VCPKG_TARGET_IS_WINDOWS)
  set(ENV{FFLAGS} "$ENV{FFLAGS} -fPIC")
endif()

vcpkg_find_fortran(FORTRAN_CMAKE)

vcpkg_configure_cmake(
  SOURCE_PATH ${SOURCE_PATH}
  PREFER_NINJA
  OPTIONS
  "-DICB=ON"
  ${FORTRAN_CMAKE}
  )

vcpkg_install_cmake()

vcpkg_cmake_config_fixup(
  PACKAGE_NAME arpack-ng
  CONFIG_PATH lib/cmake/arpack-ng
  NO_PREFIX_CORRECTION)

#
# Add relocation information to the generated CMake files
#
set(fixedfile "${CURRENT_PACKAGES_DIR}/share/arpack-ng/arpack-ng-config.cmake")
file(READ "${fixedfile}" _contents)
string(REPLACE "\${_IMPORT_PREFIX}" "\${_ARPACK_SELF_DIR}/../../" _contents "${_contents}")
string(REPLACE "INTERFACE_" "INTERFACE_LINK_DIRECTORIES \"\${libdir}\" INTERFACE_" _contents "${_contents}")
set(_contents "get_filename_component(_ARPACK_SELF_DIR \"\${CMAKE_CURRENT_LIST_FILE}\" PATH)\n${_contents}")
file(WRITE "${fixedfile}" "${_contents}")

# Handle copyright
file(INSTALL "${SOURCE_PATH}/COPYING" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)

vcpkg_fixup_pkgconfig()

# remove debug includes
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

if(VCPKG_TARGET_IS_WINDOWS)
  if(EXISTS "${CURRENT_PACKAGES_DIR}/lib/libarpack.lib")
    file(RENAME "${CURRENT_PACKAGES_DIR}/lib/libarpack.lib" "${CURRENT_PACKAGES_DIR}/lib/arpack.lib")
  endif()
  if(EXISTS "${CURRENT_PACKAGES_DIR}/debug/lib/libarpack.lib")
    file(RENAME "${CURRENT_PACKAGES_DIR}/debug/lib/libarpack.lib" "${CURRENT_PACKAGES_DIR}/debug/lib/arpack.lib")
  endif()
endif()
