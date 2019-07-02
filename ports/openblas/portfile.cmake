include(vcpkg_common_functions)

if(VCPKG_CMAKE_SYSTEM_NAME STREQUAL "Darwin")
  set(VCPKG_POLICY_EMPTY_PACKAGE enabled)
  message(WARNING "You do not need this package on macOS, since you already have the Accelerate Framework")
  return()
endif()

if(NOT VCPKG_TARGET_ARCHITECTURE STREQUAL "x64")
    message(FATAL_ERROR "openblas can only be built for x64 currently")
endif()

if(VCPKG_CMAKE_SYSTEM_NAME  STREQUAL "Linux")
  set(ADDITIONAL_PATCH "enable_underscore.patch")
endif()

if(VCPKG_LIBRARY_LINKAGE STREQUAL static)
  set(NO_SHARED 1)
endif()
if(VCPKG_LIBRARY_LINKAGE STREQUAL dynamic)
  set(NO_STATIC 1)
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO xianyi/OpenBLAS
    REF v0.3.6
    SHA512 1ad980176a51f70d8b0b2d158da8c01f30f77b7cf385b24a6340d3c5feb1513bd04b9390487d05cc9557db7dc5f7c135b1688dec9f17ebef35dba884ef7ddee9
    HEAD_REF develop
    PATCHES
        uwp.patch
        fix_space_path.patch
        ${ADDITIONAL_PATCH}
)

find_program(GIT NAMES git git.cmd)

# sed and awk are installed with git but in a different directory
get_filename_component(GIT_EXE_PATH ${GIT} DIRECTORY)
set(SED_EXE_PATH "${GIT_EXE_PATH}/../usr/bin")

# openblas require perl to generate .def for exports
vcpkg_find_acquire_program(PERL)
get_filename_component(PERL_EXE_PATH ${PERL} DIRECTORY)
set(ENV{PATH} "$ENV{PATH};${PERL_EXE_PATH};${SED_EXE_PATH}")

set(COMMON_OPTIONS -DBUILD_WITHOUT_LAPACK=ON)

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
        OPTIONS
            ${COMMON_OPTIONS}
            -DTARGET=NEHALEM
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
        OPTIONS
            ${COMMON_OPTIONS}
            -DCMAKE_SYSTEM_PROCESSOR=AMD64
            -DVS_WINRT_COMPONENT=TRUE
            "-DBLASHELPER_BINARY_DIR=${CURRENT_BUILDTREES_DIR}/x64-windows-rel")

elseif(NOT VCPKG_CMAKE_SYSTEM_NAME)
    vcpkg_configure_cmake(
        SOURCE_PATH ${SOURCE_PATH}
        OPTIONS
            ${COMMON_OPTIONS})
else()
    vcpkg_configure_cmake(
        SOURCE_PATH ${SOURCE_PATH}
        OPTIONS
            ${COMMON_OPTIONS}
            -DTARGET=SANDYBRIDGE
            -DCMAKE_SYSTEM_PROCESSOR=AMD64
            -DBINARY=64
            -DNO_SHARED=${NO_SHARED}
            -DNO_STATIC=${NO_STATIC}
            -DNOFORTRAN=ON)
endif()


vcpkg_install_cmake()
vcpkg_fixup_cmake_targets(CONFIG_PATH share/cmake/OpenBLAS)
#we install a cmake wrapper since the official FindBLAS thinks that OpenBLAS can solve also LAPACK libraries, while it cannot because we disabled it and we use CLAPACK... maybe we have to trigger finding one package when requesting the other and vice-versa. Wrappers should be ready also to avoid an infinite loop
file(INSTALL ${CMAKE_CURRENT_LIST_DIR}/vcpkg-cmake-wrapper.cmake DESTINATION ${CURRENT_PACKAGES_DIR}/share/blas)
vcpkg_copy_pdbs()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include ${CURRENT_PACKAGES_DIR}/debug/share)

file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/openblas RENAME copyright)
