#TODO: Features to add:
# USE_XBLAS??? extended precision blas. needs xblas
# LAPACKE should be its own PORT
# USE_OPTIMIZED_LAPACK (Probably not what we want. Does a find_package(LAPACK): probably for LAPACKE only builds _> own port?)
# LAPACKE Builds LAPACKE
# LAPACKE_WITH_TMG Build LAPACKE with tmglib routines
if(EXISTS "${CURRENT_INSTALLED_DIR}/share/clapack/copyright")
    message(FATAL_ERROR "Can't build ${PORT} if clapack is installed. Please remove clapack:${TARGET_TRIPLET}, and try to install ${PORT}:${TARGET_TRIPLET} again.")
endif()

include(vcpkg_find_fortran)
SET(VCPKG_POLICY_EMPTY_INCLUDE_FOLDER enabled)
set(VCPKG_POLICY_ALLOW_OBSOLETE_MSVCRT enabled)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO  "Reference-LAPACK/lapack"
    REF "v${VERSION}"
    SHA512 f8f3c733a0221be0b3f5618235408ac59cbd4e5f1c4eab5f509b831a6ec6a9ef14b8849aa6ea10810df1aff90186ca454d15e9438d1dd271c2449d42d3da9dda
    HEAD_REF master
    PATCHES
        fix-prefix.patch
        cmake-config.patch
        print-implicit-libs.patch
)

if(NOT VCPKG_TARGET_IS_WINDOWS)
    set(ENV{FFLAGS} "$ENV{FFLAGS} -fPIC") # should come from toolchain
endif()

set(CBLAS OFF)
if("cblas" IN_LIST FEATURES)
    set(CBLAS ON)
    if("noblas" IN_LIST FEATURES)
        message(FATAL_ERROR "Cannot built feature 'cblas' together with feature 'noblas'. cblas requires blas!")
    endif()
endif()

set(USE_OPTIMIZED_BLAS OFF)
if("noblas" IN_LIST FEATURES)
    set(USE_OPTIMIZED_BLAS ON)
endif()

set(VCPKG_CRT_LINKAGE_BACKUP ${VCPKG_CRT_LINKAGE})
vcpkg_find_fortran(FORTRAN_CMAKE)
if(VCPKG_USE_INTERNAL_Fortran)
    if(VCPKG_CRT_LINKAGE_BACKUP STREQUAL "static")
    # If openblas has been built with static crt linkage we cannot use it with gfortran!
        set(USE_OPTIMIZED_BLAS OFF)
        #Cannot use openblas from vcpkg if we are building with gfortran here.
        if("noblas" IN_LIST FEATURES)
            message(FATAL_ERROR "Feature 'noblas' cannot be used without supplying an external fortran compiler")
        endif()
    endif()
endif()

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        "-DUSE_OPTIMIZED_BLAS=${USE_OPTIMIZED_BLAS}"
        "-DCMAKE_REQUIRE_FIND_PACKAGE_BLAS=${USE_OPTIMIZED_BLAS}"
        "-DCBLAS=${CBLAS}"
        "-DTEST_FORTRAN_COMPILER=OFF"
        "-DCMAKE_Fortran_INIT_FLAGS=-fno-tree-vectorize" # This is used by openblas to compile lapack since there seems to be a bug in gfortran
        ${FORTRAN_CMAKE}
    MAYBE_UNUSED_VARIABLES
        CMAKE_REQUIRE_FIND_PACKAGE_BLAS
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(PACKAGE_NAME ${PORT} CONFIG_PATH lib/cmake/lapack-${VERSION}) #Should the target path be lapack and not lapack-reference?

set(pcfile "${CURRENT_PACKAGES_DIR}/lib/pkgconfig/lapack.pc")
if(EXISTS "${pcfile}")
    file(READ "${pcfile}" _contents)
    file(WRITE "${pcfile}" "prefix=${CURRENT_INSTALLED_DIR}\n${_contents}")
endif()
set(pcfile "${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig/lapack.pc")
if(EXISTS "${pcfile}")
    file(READ "${pcfile}" _contents)
    file(WRITE "${pcfile}" "prefix=${CURRENT_INSTALLED_DIR}/debug\n${_contents}")
endif()

if(NOT USE_OPTIMIZED_BLAS AND NOT (VCPKG_TARGET_IS_WINDOWS AND VCPKG_LIBRARY_LINKAGE STREQUAL "static"))
    set(pcfile "${CURRENT_PACKAGES_DIR}/lib/pkgconfig/blas.pc")
    if(EXISTS "${pcfile}")
        file(READ "${pcfile}" _contents)
        file(WRITE "${pcfile}" "prefix=${CURRENT_INSTALLED_DIR}\n${_contents}")
    endif()
    set(pcfile "${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig/blas.pc")
    if(EXISTS "${pcfile}")
        file(READ "${pcfile}" _contents)
        file(WRITE "${pcfile}" "prefix=${CURRENT_INSTALLED_DIR}/debug\n${_contents}")
    endif()
endif()
if("cblas" IN_LIST FEATURES)
    set(pcfile "${CURRENT_PACKAGES_DIR}/lib/pkgconfig/cblas.pc")
    if(EXISTS "${pcfile}")
        file(READ "${pcfile}" _contents)
        file(WRITE "${pcfile}" "prefix=${CURRENT_INSTALLED_DIR}\n${_contents}")
    endif()
    set(pcfile "${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig/cblas.pc")
    if(EXISTS "${pcfile}")
        file(READ "${pcfile}" _contents)
        file(WRITE "${pcfile}" "prefix=${CURRENT_INSTALLED_DIR}/debug\n${_contents}")
    endif()
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/lib/pkgconfig/lapack.pc" " blas" " blas cblas")
    if(NOT VCPKG_BUILD_TYPE)
      vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig/lapack.pc" " blas" " blas cblas")
    endif()
endif()
vcpkg_fixup_pkgconfig()

file(RENAME "${CURRENT_PACKAGES_DIR}/lib/pkgconfig/lapack.pc" "${CURRENT_PACKAGES_DIR}/lib/pkgconfig/lapack-reference.pc")
if(NOT VCPKG_BUILD_TYPE)
    file(RENAME "${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig/lapack.pc" "${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig/lapack-reference.pc")
endif()

if(NOT "noblas" IN_LIST FEATURES)
    file(RENAME "${CURRENT_PACKAGES_DIR}/lib/pkgconfig/blas.pc" "${CURRENT_PACKAGES_DIR}/lib/pkgconfig/blas-reference.pc")
    if(NOT VCPKG_BUILD_TYPE)
        file(RENAME "${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig/blas.pc" "${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig/blas-reference.pc")
    endif()
    if("cblas" IN_LIST FEATURES)
      file(RENAME "${CURRENT_PACKAGES_DIR}/lib/pkgconfig/cblas.pc" "${CURRENT_PACKAGES_DIR}/lib/pkgconfig/cblas-reference.pc")
      if(NOT VCPKG_BUILD_TYPE)
          file(RENAME "${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig/cblas.pc" "${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig/cblas-reference.pc")
      endif()
    endif()
endif()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

if(VCPKG_TARGET_IS_WINDOWS)
    if(NOT USE_OPTIMIZED_BLAS)
        if(EXISTS "${CURRENT_PACKAGES_DIR}/lib/libblas.lib")
            file(RENAME "${CURRENT_PACKAGES_DIR}/lib/libblas.lib" "${CURRENT_PACKAGES_DIR}/lib/blas.lib")
        endif()
        if(EXISTS "${CURRENT_PACKAGES_DIR}/debug/lib/libblas.lib")
            file(RENAME "${CURRENT_PACKAGES_DIR}/debug/lib/libblas.lib" "${CURRENT_PACKAGES_DIR}/debug/lib/blas.lib")
        endif()
    endif()
endif()

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    set(BLA_STATIC ON)
else()
    set(BLA_STATIC OFF)
endif()
set(BLA_VENDOR Generic)

configure_file("${CMAKE_CURRENT_LIST_DIR}/vcpkg-cmake-wrapper.cmake.in" "${CURRENT_PACKAGES_DIR}/share/${PORT}/wrapper/vcpkg-cmake-wrapper.cmake" @ONLY)
file(COPY "${CMAKE_CURRENT_LIST_DIR}/FindLAPACK.cmake" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")

if(NOT VCPKG_TARGET_IS_WINDOWS)
  file(READ "${CURRENT_BUILDTREES_DIR}/config-${TARGET_TRIPLET}-out.log" config_log)
  string(REGEX MATCH "CMAKE_C_IMPLICIT_LINK_LIBRARIES:([^\n]+)" implicit_c_libs "${config_log}")
  set(implicit_c_libs "${CMAKE_MATCH_1}")
  list(REVERSE implicit_c_libs)
  list(REMOVE_DUPLICATES implicit_c_libs)
  list(REVERSE implicit_c_libs)
  string(REGEX MATCH "CMAKE_Fortran_IMPLICIT_LINK_LIBRARIES:([^\n]+)" implicit_fortran_libs "${config_log}")
  set(implicit_fortran_libs "${CMAKE_MATCH_1}")
  list(REVERSE implicit_fortran_libs)
  list(REMOVE_DUPLICATES implicit_fortran_libs)
  list(REVERSE implicit_fortran_libs)
  list(REMOVE_ITEM implicit_fortran_libs ${implicit_c_libs} quadmath m) # libgfortran already has quadmath and m as a dependency
  list(JOIN implicit_fortran_libs " -l" implicit_fortran_libs)
  
  string(REGEX MATCH "CMAKE_C_IMPLICIT_LINK_DIRECTORIES:([^\n]+)" implicit_c_dirs "${config_log}")
  set(implicit_c_dirs "${CMAKE_MATCH_1}")
  list(REVERSE implicit_c_dirs)
  list(REMOVE_DUPLICATES implicit_c_dirs)
  list(REVERSE implicit_c_dirs)
  string(REGEX MATCH "CMAKE_Fortran_IMPLICIT_LINK_DIRECTORIES:([^\n]+)" implicit_fortran_dirs "${config_log}")
  set(implicit_fortran_dirs "${CMAKE_MATCH_1}")
  list(REVERSE implicit_fortran_dirs)
  list(REMOVE_DUPLICATES implicit_fortran_dirs)
  list(REVERSE implicit_fortran_dirs)
  list(REMOVE_ITEM implicit_fortran_dirs ${implicit_c_dirs}) # libgfortran already has quadmath and m as a dependency
  if(VCPKG_TARGET_IS_OSX)
   list(APPEND implicit_fortran_dirs "/usr/local/lib")
  endif()
  list(JOIN implicit_fortran_dirs " -L" implicit_fortran_dirs)

  message(STATUS "implicit_fortran_libs:${implicit_fortran_libs}|implicit_c_libs:${implicit_c_libs}")
  message(STATUS "implicit_fortran_dirs:${implicit_fortran_dirs}|implicit_c_dirs:${implicit_c_dirs}")
  if(NOT implicit_fortran_libs STREQUAL "" AND NOT implicit_fortran_dirs STREQUAL "")
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/lib/pkgconfig/lapack-reference.pc" "-llapack" "-llapack -L${implicit_fortran_dirs} -l${implicit_fortran_libs}")
    if(NOT VCPKG_BUILD_TYPE)
        vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig/lapack-reference.pc" "-llapack" "-llapack -L${implicit_fortran_dirs} -l${implicit_fortran_libs}")
    endif()
  elseif(NOT implicit_fortran_libs STREQUAL "")
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/lib/pkgconfig/lapack-reference.pc" "-llapack" "-llapack -l${implicit_fortran_libs}")
    if(NOT VCPKG_BUILD_TYPE)
        vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig/lapack-reference.pc" "-llapack" "-llapack -l${implicit_fortran_libs}")
    endif()
  endif()
endif()
