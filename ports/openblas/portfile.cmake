# Common Ambient Variables:
#   CURRENT_BUILDTREES_DIR    = ${VCPKG_ROOT_DIR}\buildtrees\${PORT}
#   CURRENT_PACKAGES_DIR      = ${VCPKG_ROOT_DIR}\packages\${PORT}_${TARGET_TRIPLET}
#   CURRENT_PORT DIR          = ${VCPKG_ROOT_DIR}\ports\${PORT}
#   PORT                      = current port name (zlib, etc)
#   TARGET_TRIPLET            = current triplet (x86-windows, x64-windows-static, etc)
#   VCPKG_CRT_LINKAGE         = C runtime linkage type (static, dynamic)
#   VCPKG_LIBRARY_LINKAGE     = target library linkage type (static, dynamic)
#   VCPKG_ROOT_DIR            = <C:\path\to\current\vcpkg>
#   VCPKG_TARGET_ARCHITECTURE = target architecture (x64, x86, arm)
#

include(vcpkg_common_functions)

if(NOT VCPKG_TARGET_ARCHITECTURE STREQUAL "x64")
    message(FATAL_ERROR "openblas can only be built for x64 currently")
endif()

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    message("openblas currenly only supports dynamic library linkage")
    set(VCPKG_LIBRARY_LINKAGE "dynamic")
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO xianyi/OpenBLAS
    REF v0.3.5
    SHA512 91b3074eb922453bf843158b4281cde65db9e8bbdd7590e75e9e6cdcb486157f7973f2936f327bb3eb4f1702ce0ba51ae6729d8d4baf2d986c50771e8f696df0
    HEAD_REF develop
)

vcpkg_apply_patches(
    SOURCE_PATH ${SOURCE_PATH}
    PATCHES "${CMAKE_CURRENT_LIST_DIR}/uwp.patch"
)

find_program(GIT NAMES git git.cmd)

# sed and awk are installed with git but in a different directory
get_filename_component(GIT_EXE_PATH ${GIT} DIRECTORY)
set(SED_EXE_PATH "${GIT_EXE_PATH}/../usr/bin")

# openblas require perl to generate .def for exports
vcpkg_find_acquire_program(PERL)
get_filename_component(PERL_EXE_PATH ${PERL} DIRECTORY)
set(ENV{PATH} "$ENV{PATH};${PERL_EXE_PATH};${SED_EXE_PATH}")

# for UWP version, must build non uwp first for helper
# binaries.
if(VCPKG_CMAKE_SYSTEM_NAME  STREQUAL "WindowsStore")
    message(STATUS "Building Windows helper files")
    set(TEMP_CMAKE_SYSTEM_NAME "${VCPKG_CMAKE_SYSTEM_NAME}")
    set(TEMP_CMAKE_SYSTEM_VERSION "${VCPKG_CMAKE_SYSTEM_VERSION}")
    set(TEMP_TARGET_TRIPLET "${TARGET_TRIPLET}")
    unset(VCPKG_CMAKE_SYSTEM_NAME)
    unset(VCPKG_CMAKE_SYSTEM_VERSION)
    set(TARGET_TRIPLET "x64-windows")

    vcpkg_configure_cmake(
        SOURCE_PATH ${SOURCE_PATH}
        OPTIONS -DTARGET=NEHALEM -DBUILD_WITHOUT_LAPACK=ON
    )

    # add just built path to environment for gen_config_h.exe,
    # getarch.exe and getarch_2nd.exe
    set(ENV{PATH} "$ENV{PATH};${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel")

    # restore target build information
    set(VCPKG_CMAKE_SYSTEM_NAME "${TEMP_CMAKE_SYSTEM_NAME}")
    set(VCPKG_CMAKE_SYSTEM_VERSION "${TEMP_CMAKE_SYSTEM_VERSION}")
    set(TARGET_TRIPLET "${TEMP_TARGET_TRIPLET}")

    message(STATUS "Finished building Windows helper files")

    vcpkg_configure_cmake(
        SOURCE_PATH ${SOURCE_PATH}
        OPTIONS -DCMAKE_SYSTEM_PROCESSOR=AMD64 -DVS_WINRT_COMPONENT=TRUE -DBUILD_WITHOUT_LAPACK=ON 
        "-DBLASHELPER_BINARY_DIR=${CURRENT_BUILDTREES_DIR}/x64-windows-rel")

elseif(NOT VCPKG_CMAKE_SYSTEM_NAME)
    vcpkg_configure_cmake(
        SOURCE_PATH ${SOURCE_PATH}
        OPTIONS -DBUILD_WITHOUT_LAPACK=ON)
else()
    vcpkg_configure_cmake(
        SOURCE_PATH ${SOURCE_PATH}
        OPTIONS -DCMAKE_SYSTEM_PROCESSOR=AMD64 -DNOFORTRAN=ON)
endif()


vcpkg_install_cmake()

# openblas do not make the config file , so I manually made this
# but I think in most case, libraries will not include these files, they define their own used function prototypes
# this is only to quite vcpkg
file(COPY ${CMAKE_CURRENT_LIST_DIR}/openblas_common.h DESTINATION ${CURRENT_PACKAGES_DIR}/include)

file(READ ${SOURCE_PATH}/cblas.h CBLAS_H)
string(REPLACE "#include \"common.h\"" "#include \"openblas_common.h\"" CBLAS_H "${CBLAS_H}")
file(WRITE ${CURRENT_PACKAGES_DIR}/include/cblas.h "${CBLAS_H}")

# openblas is BSD
file(COPY ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/openblas)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/openblas/LICENSE ${CURRENT_PACKAGES_DIR}/share/openblas/copyright)

vcpkg_copy_pdbs()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include ${CURRENT_PACKAGES_DIR}/debug/share)
