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

set(lapack_ver 3.8.0)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO "Reference-LAPACK/lapack"
    REF "v${lapack_ver}"
    SHA512 17786cb7306fccdc9b4a242de7f64fc261ebe6a10b6ec55f519deb4cb673cb137e8742aa5698fd2dc52f1cd56d3bd116af3f593a01dcf6770c4dcc86c50b2a7f
    HEAD_REF master
)

if(NOT VCPKG_TARGET_IS_WINDOWS)
    set(ENV{FFLAGS} "$ENV{FFLAGS} -fPIC")
endif()

set(VCPKG_CRT_LINKAGE_BACKUP ${VCPKG_CRT_LINKAGE})
vcpkg_find_fortran(FORTRAN_CMAKE)
if(VCPKG_USE_INTERNAL_Fortran AND VCPKG_TARGET_IS_WINDOWS)
    if(VCPKG_CRT_LINKAGE_BACKUP STREQUAL "static") 
        message(FATAL_ERROR [[Lapack-reference cannot be built with:
- Static CRT
- and Windows
- and the built-in vcpkg Fortran compiler (gfortran).

This issue can be resolved by changing any of these, for example:
1. By using a dynamic CRT triplet like x64-windows-static-md
2. By providing your own Fortran compiler such as ifort
]])
    endif()
endif()

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        "-DUSE_OPTIMIZED_BLAS=ON"
        "-DCBLAS=${CBLAS}"
        ${FORTRAN_CMAKE}
)

vcpkg_install_cmake()

vcpkg_cmake_config_fixup(PACKAGE_NAME lapack CONFIG_PATH lib/cmake/lapack-${lapack_ver})

vcpkg_fixup_pkgconfig()

# Handle copyright
file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)

# remove debug includes
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

if(VCPKG_TARGET_IS_WINDOWS)
    if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
        file(RENAME "${CURRENT_PACKAGES_DIR}/lib/liblapack.dll.a" "${CURRENT_PACKAGES_DIR}/lib/lapack.lib")
        if(NOT VCPKG_BUILD_TYPE)
            file(RENAME "${CURRENT_PACKAGES_DIR}/debug/lib/liblapack.dll.a" "${CURRENT_PACKAGES_DIR}/debug/lib/lapack.lib")
        endif()
    else()
        file(REMOVE "${CURRENT_PACKAGES_DIR}/lib/liblapack.dll.a" "${CURRENT_PACKAGES_DIR}/debug/lib/liblapack.dll.a")
    endif()
    if(NOT USE_OPTIMIZED_BLAS)
        if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
            file(RENAME "${CURRENT_PACKAGES_DIR}/lib/libblas.dll.a" "${CURRENT_PACKAGES_DIR}/lib/blas.lib")
            if(NOT VCPKG_BUILD_TYPE)
                file(RENAME "${CURRENT_PACKAGES_DIR}/debug/lib/libblas.dll.a" "${CURRENT_PACKAGES_DIR}/debug/lib/blas.lib")
            endif()
        else()
            file(REMOVE "${CURRENT_PACKAGES_DIR}/lib/libblas.dll.a" "${CURRENT_PACKAGES_DIR}/debug/lib/libblas.dll.a")
        endif()
    endif()
endif()

file(COPY ${CMAKE_CURRENT_LIST_DIR}/vcpkg-cmake-wrapper.cmake DESTINATION ${CURRENT_PACKAGES_DIR}/share/lapack)
configure_file("${CMAKE_CURRENT_LIST_DIR}/usage" "${CURRENT_PACKAGES_DIR}/share/${PORT}/usage" @ONLY)
