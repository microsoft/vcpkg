#TODO: Features to add:
# USE_XBLAS??? extended precision blas. needs xblas
# LAPACKE should be its own PORT
# USE_OPTIMIZED_LAPACK (Probably not what we want. Does a find_package(LAPACK): probably for LAPACKE only builds _> own port?)
# LAPACKE Builds LAPACKE
# LAPACKE_WITH_TMG Build LAPACKE with tmglib routines
if(EXISTS "${CURRENT_INSTALLED_DIR}/share/clapack/copyright")
    message(FATAL_ERROR "Can't build ${PORT} if clapack is installed. Please remove clapack:${TARGET_TRIPLET}, and try to install ${PORT}:${TARGET_TRIPLET} again.")
endif()

SET(VCPKG_POLICY_EMPTY_INCLUDE_FOLDER enabled)

set(lapack_ver 3.10.0)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO  "Reference-LAPACK/lapack"
    REF "v${lapack_ver}"
    SHA512 56055000c241bab8f318ebd79249ea012c33be0c4c3eca6a78e247f35ad9e8088f46605a0ba52fd5ad3e7898be3b7bc6c50ceb3af327c4986a266b06fe768cbf
    HEAD_REF master
    PATCHES intel.patch
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
x_vcpkg_find_fortran(FORTRAN_CMAKE)

vcpkg_configure_cmake(
        PREFER_NINJA
        SOURCE_PATH ${SOURCE_PATH}
        OPTIONS
            "-DUSE_OPTIMIZED_BLAS=${USE_OPTIMIZED_BLAS}"
            "-DBLA_VENDOR=OpenBLAS"
            "-DCBLAS=${CBLAS}"
            ${FORTRAN_CMAKE}
        )

vcpkg_install_cmake()
vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/lapack-${lapack_ver}) #Should the target path be lapack and not lapack-reference?

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
if(NOT USE_OPTIMIZED_BLAS)
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
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

file(COPY ${CMAKE_CURRENT_LIST_DIR}/vcpkg-cmake-wrapper.cmake DESTINATION ${CURRENT_PACKAGES_DIR}/share/lapack)
file(COPY ${CMAKE_CURRENT_LIST_DIR}/FindLAPACK.cmake DESTINATION ${CURRENT_PACKAGES_DIR}/share/lapack)
