include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO xianyi/OpenBLAS
    REF 5f36f18148603facb6c3540e673610d6b24cbfbb # v0.3.7
    SHA512 c1abcfd6fbf6ae3efa28053523ffb3d72aefaa279594347bfd9910c40f25778421b8d1d2d4dc6c934c9def40642942bb74fe76e06c2d96b1898ea61204a95540
    HEAD_REF develop
    PATCHES
        uwp.patch
        fix-space-path.patch
        fix-redefinition-function.patch
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
        PREFER_NINJA
        SOURCE_PATH ${SOURCE_PATH}
        OPTIONS
            ${COMMON_OPTIONS})
else()
    list(APPEND VCPKG_C_FLAGS "-DNEEDBUNDERSCORE") # Required to get common BLASFUNC to append extra _
    list(APPEND VCPKG_CXX_FLAGS "-DNEEDBUNDERSCORE")
    vcpkg_configure_cmake(
        SOURCE_PATH ${SOURCE_PATH}
        OPTIONS
            ${COMMON_OPTIONS}
            -DCMAKE_SYSTEM_PROCESSOR=AMD64
            -DNOFORTRAN=ON
            -DBU=_  #required for all blas functions to append extra _ using NAME
            )
endif()


vcpkg_install_cmake()
vcpkg_fixup_cmake_targets(CONFIG_PATH share/cmake/OpenBLAS TARGET_PATH share/openblas)
vcpkg_fixup_pkgconfig()
file(COPY "${CURRENT_PACKAGES_DIR}/lib/pkgconfig/openblas.pc" "${CURRENT_PACKAGES_DIR}/lib/pkgconfig/blas.pc")
if(EXISTS "${CURRENT_PACKAGES_DIR}/debug/")
    file(COPY "${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig/openblas.pc" "${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig/blas.pc")
endif()
#maybe we need also to write a wrapper inside share/blas to search implicitly for openblas, whenever we feel it's ready for its own -config.cmake file

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

file(COPY ${CMAKE_CURRENT_LIST_DIR}/vcpkg-cmake-wrapper.cmake DESTINATION ${CURRENT_PACKAGES_DIR}/share/blas)
file(COPY ${CMAKE_CURRENT_LIST_DIR}/FindBLAS.cmake DESTINATION ${CURRENT_PACKAGES_DIR}/share/blas)

vcpkg_copy_pdbs()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include ${CURRENT_PACKAGES_DIR}/debug/share)
