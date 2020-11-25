vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO xianyi/OpenBLAS
    REF c5f280a7f0e875d83833d895b2b8b0e341efabf4 # v0.3.12
    SHA512 5506cfcc86b3b0c2e8fc320b779a92daaf9c5ca78671c270d5355dc707bdb112ad486f5e97d771e1ec7c907fba9d6daf2e3485bd7852c95fe3e3e22ae0902488
    HEAD_REF develop
    PATCHES
        fix-uwp-build.patch
)

find_program(GIT NAMES git git.cmd)

# sed and awk are installed with git but in a different directory
get_filename_component(GIT_EXE_PATH ${GIT} DIRECTORY)
set(SED_EXE_PATH "${GIT_EXE_PATH}/../usr/bin")

# openblas require perl to generate .def for exports
vcpkg_find_acquire_program(PERL)
get_filename_component(PERL_EXE_PATH ${PERL} DIRECTORY)
set(PATH_BACKUP "$ENV{PATH}")
vcpkg_add_to_path("${PERL_EXE_PATH}")
vcpkg_add_to_path("${SED_EXE_PATH}")

set(COMMON_OPTIONS -DBUILD_WITHOUT_LAPACK=ON)

# for UWP version, must build non uwp first for helper
# binaries.
if(VCPKG_TARGET_IS_UWP)
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
    vcpkg_add_to_path("${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel")

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

elseif(VCPKG_TARGET_IS_WINDOWS)
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
set(ENV{PATH} "${PATH_BACKUP}")

set(pcfile "${CURRENT_PACKAGES_DIR}/lib/pkgconfig/openblas.pc")
if(EXISTS "${pcfile}")
    file(READ "${pcfile}" _contents)
    set(_contents "prefix=${CURRENT_INSTALLED_DIR}\n${_contents}")
    file(WRITE "${pcfile}" "${_contents}")
    #file(CREATE_LINK "${pcfile}" "${CURRENT_PACKAGES_DIR}/lib/pkgconfig/blas.pc" COPY_ON_ERROR)
endif()
set(pcfile "${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig/openblas.pc")
if(EXISTS "${pcfile}")
    file(READ "${pcfile}" _contents)
    set(_contents "prefix=${CURRENT_INSTALLED_DIR}/debug\n${_contents}")
    file(WRITE "${pcfile}" "${_contents}")
    #file(CREATE_LINK "${pcfile}" "${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig/blas.pc" COPY_ON_ERROR)
endif()
vcpkg_fixup_pkgconfig()
#maybe we need also to write a wrapper inside share/blas to search implicitly for openblas, whenever we feel it's ready for its own -config.cmake file

# openblas do not make the config file , so I manually made this
# but I think in most case, libraries will not include these files, they define their own used function prototypes
# this is only to quite vcpkg
file(COPY ${CMAKE_CURRENT_LIST_DIR}/openblas_common.h DESTINATION ${CURRENT_PACKAGES_DIR}/include)

file(READ ${SOURCE_PATH}/cblas.h CBLAS_H)
string(REPLACE "#include \"common.h\"" "#include \"openblas_common.h\"" CBLAS_H "${CBLAS_H}")
file(WRITE ${CURRENT_PACKAGES_DIR}/include/cblas.h "${CBLAS_H}")

vcpkg_copy_pdbs()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include ${CURRENT_PACKAGES_DIR}/debug/share)

file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
