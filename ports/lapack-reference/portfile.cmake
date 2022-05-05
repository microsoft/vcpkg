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

set(lapack_ver 3.10.0)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO  "Reference-LAPACK/lapack"
    REF "v${lapack_ver}"
    SHA512 56055000c241bab8f318ebd79249ea012c33be0c4c3eca6a78e247f35ad9e8088f46605a0ba52fd5ad3e7898be3b7bc6c50ceb3af327c4986a266b06fe768cbf
    HEAD_REF master
)

if(NOT VCPKG_TARGET_IS_WINDOWS)
    set(ENV{FFLAGS} "$ENV{FFLAGS} -fPIC")
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
    set(pcfile "${CURRENT_INSTALLED_DIR}/lib/pkgconfig/openblas.pc")
    if(EXISTS "${pcfile}")
        file(CREATE_LINK "${pcfile}" "${CURRENT_PACKAGES_DIR}/lib/pkgconfig/blas.pc" COPY_ON_ERROR)
    endif()
    set(pcfile "${CURRENT_INSTALLED_DIR}/debug/lib/pkgconfig/openblas.pc")
    if(EXISTS "${pcfile}")
        file(CREATE_LINK "${pcfile}" "${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig/blas.pc" COPY_ON_ERROR)
    endif()
endif()

set(VCPKG_CRT_LINKAGE_BACKUP ${VCPKG_CRT_LINKAGE})
vcpkg_find_fortran(FORTRAN_CMAKE)
if(VCPKG_USE_INTERNAL_Fortran)
    if(VCPKG_CRT_LINKAGE_BACKUP STREQUAL static) 
    # If openblas has been built with static crt linkage we cannot use it with gfortran!
        set(USE_OPTIMIZED_BLAS OFF) 
        #Cannot use openblas from vcpkg if we are building with gfortran here. 
        if("noblas" IN_LIST FEATURES)
            message(FATAL_ERROR "Feature 'noblas' cannot be used without supplying an external fortran compiler")
        endif()
    endif()
else()
    set(USE_OPTIMIZED_BLAS ON)
endif()

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        "-DUSE_OPTIMIZED_BLAS=${USE_OPTIMIZED_BLAS}"
        "-DCBLAS=${CBLAS}"
        ${FORTRAN_CMAKE}
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(PACKAGE_NAME lapack-${lapack_ver} CONFIG_PATH lib/cmake/lapack-${lapack_ver}) #Should the target path be lapack and not lapack-reference?

set(pcfile "${CURRENT_PACKAGES_DIR}/lib/pkgconfig/lapack.pc")
if(EXISTS "${pcfile}")
    file(READ "${pcfile}" _contents)
    set(_contents "prefix=${CURRENT_INSTALLED_DIR}\n${_contents}")
    file(WRITE "${pcfile}" "${_contents}")
endif()
set(pcfile "${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig/lapack.pc")
if(EXISTS "${pcfile}")
    file(READ "${pcfile}" _contents)
    set(_contents "prefix=${CURRENT_INSTALLED_DIR}/debug\n${_contents}")
    file(WRITE "${pcfile}" "${_contents}")
endif()
if(NOT USE_OPTIMIZED_BLAS AND NOT (VCPKG_TARGET_IS_WINDOWS AND VCPKG_LIBRARY_LINKAGE STREQUAL "static"))
    set(pcfile "${CURRENT_PACKAGES_DIR}/lib/pkgconfig/blas.pc")
    if(EXISTS "${pcfile}")
        file(READ "${pcfile}" _contents)
        set(_contents "prefix=${CURRENT_INSTALLED_DIR}\n${_contents}")
        file(WRITE "${pcfile}" "${_contents}")
    endif()
    set(pcfile "${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig/blas.pc")
    if(EXISTS "${pcfile}")
        file(READ "${pcfile}" _contents)
        set(_contents "prefix=${CURRENT_INSTALLED_DIR}/debug\n${_contents}")
        file(WRITE "${pcfile}" "${_contents}")
    endif()
endif()
if("cblas" IN_LIST FEATURES)
    set(pcfile "${CURRENT_PACKAGES_DIR}/lib/pkgconfig/cblas.pc")
    if(EXISTS "${pcfile}")
        file(READ "${pcfile}" _contents)
        set(_contents "prefix=${CURRENT_INSTALLED_DIR}\n${_contents}")
        file(WRITE "${pcfile}" "${_contents}")
    endif()
    set(pcfile "${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig/cblas.pc")
    if(EXISTS "${pcfile}")
        file(READ "${pcfile}" _contents)
        set(_contents "prefix=${CURRENT_INSTALLED_DIR}/debug\n${_contents}")
        file(WRITE "${pcfile}" "${_contents}")
    endif()
endif()
vcpkg_fixup_pkgconfig()

# Handle copyright
file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)

# remove debug includes
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

if(VCPKG_TARGET_IS_WINDOWS)
    if(EXISTS "${CURRENT_PACKAGES_DIR}/lib/liblapack.lib")
        file(RENAME "${CURRENT_PACKAGES_DIR}/lib/liblapack.lib" "${CURRENT_PACKAGES_DIR}/lib/lapack.lib")
    endif()
    if(EXISTS "${CURRENT_PACKAGES_DIR}/debug/lib/liblapack.lib")
        file(RENAME "${CURRENT_PACKAGES_DIR}/debug/lib/liblapack.lib" "${CURRENT_PACKAGES_DIR}/debug/lib/lapack.lib")
    endif()
    if(NOT USE_OPTIMIZED_BLAS)
        if(EXISTS "${CURRENT_PACKAGES_DIR}/lib/libblas.lib")
            file(RENAME "${CURRENT_PACKAGES_DIR}/lib/libblas.lib" "${CURRENT_PACKAGES_DIR}/lib/blas.lib")
        endif()
        if(EXISTS "${CURRENT_PACKAGES_DIR}/debug/lib/libblas.lib")
            file(RENAME "${CURRENT_PACKAGES_DIR}/debug/lib/libblas.lib" "${CURRENT_PACKAGES_DIR}/debug/lib/blas.lib")
        endif()
    endif()
endif()

file(COPY ${CMAKE_CURRENT_LIST_DIR}/vcpkg-cmake-wrapper.cmake DESTINATION ${CURRENT_PACKAGES_DIR}/share/lapack)
file(COPY ${CMAKE_CURRENT_LIST_DIR}/FindLAPACK.cmake DESTINATION ${CURRENT_PACKAGES_DIR}/share/lapack)
