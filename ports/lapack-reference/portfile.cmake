#TODO: Features to add:
# USE_XBLAS??? extended precision blas. needs xblas

# LAPACKE should be its own PORT
# USE_OPTIMIZED_LAPACK (Probably not what we want. Does a find_package(LAPACK): probably for LAPACKE only builds _> own port?)
# LAPACKE Builds LAPACKE
# LAPACKE_WITH_TMG Build LAPACKE with tmglib routines

SET(VCPKG_POLICY_EMPTY_INCLUDE_FOLDER enabled)

include(vcpkg_common_functions)

vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

set(VCPKG_ENABLE_Fortran ON)
if(VCPKG_TARGET_IS_WINDOWS)
    vcpkg_acquire_msys(MSYS_ROOT PACKAGES "mingw-w64-x86_64-gcc-fortran")
    set(NINJA "${CMAKE_CURRENT_LIST_DIR}/ninja.exe")
    #vcpkg_add_to_path("${MSYS_ROOT}/usr/bin")${MSYS_ROOT}/mingw64/bin/
    set(BASH "${MSYS_ROOT}/usr/bin/bash.exe")
    set(base_cmd ${BASH} --noprofile --norc -c ${MSYS_ROOT}/usr/share/automake-1.16/compile cl.exe)
    set(ENV{CC} "cl.exe")
    set(ENV{RC} "rc.exe")
    set(ENV{LD} "link.exe")
    set(ENV{AR} "link.exe")
    vcpkg_add_to_path("${MSYS_ROOT}/mingw64/bin/")
    #set(ENV{FC} "${MSYS_ROOT}/mingw64/bin/gfortran.exe")
endif()
#vcpkg_enable_fortran()

set(lapack_ver 3.8.0)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO  "Reference-LAPACK/lapack"
    REF "v${lapack_ver}"
    SHA512 17786cb7306fccdc9b4a242de7f64fc261ebe6a10b6ec55f519deb4cb673cb137e8742aa5698fd2dc52f1cd56d3bd116af3f593a01dcf6770c4dcc86c50b2a7f
    HEAD_REF master
)

set(USE_OPTIMIZED_BLAS OFF)
if("noblas" IN_LIST FEATURES)
    set(USE_OPTIMIZED_BLAS ON)
endif()

set(CBLAS OFF)
if("cblas" IN_LIST FEATURES)
    set(CBLAS ON)
endif()

vcpkg_configure_cmake(
        PREFER_NINJA
        SOURCE_PATH ${SOURCE_PATH}
        OPTIONS
            #"-DCMAKE_SYSTEM_NAME=Windows-GNU"
            #"-DCMAKE_C_COMPILER=${base_cmd}"
            #"-DCMAKE_Fortran_COMPILER=${MSYS_ROOT}/mingw64/bin/gfortran.exe"
            "-DCMAKE_LINKER=link.exe"
            "-DUSE_OPTIMIZED_BLAS=${USE_OPTIMIZED_BLAS}"
            "-DCBLAS=${CBLAS}"
        )

vcpkg_install_cmake()
vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/lapack-${lapack_ver}) #Should the target path be lapack and not lapack-reference?
vcpkg_copy_pdbs()

# Handle copyright
file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)

# remove debug includs
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
