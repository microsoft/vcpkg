vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO OpenMathLib/OpenBLAS
    REF "v${VERSION}"
    SHA512 4accc5282244946157b7940211181e011940154ff47855702c68f57a0af2fa5a306f49e47b8c22c02eeff61760c6c220465f05a316a33ee3265bfce65ca4cb84
    HEAD_REF develop
    PATCHES
        uwp.patch
        fix-redefinition-function.patch
        install-tools.patch
        gcc14.patch
)

find_program(GIT NAMES git git.cmd)

# sed and awk are installed with git but in a different directory
get_filename_component(GIT_EXE_PATH "${GIT}" DIRECTORY)
set(SED_EXE_PATH "${GIT_EXE_PATH}/../usr/bin")

# openblas requires perl to generate .def for exports
vcpkg_find_acquire_program(PERL)
get_filename_component(PERL_EXE_PATH "${PERL}" DIRECTORY)
set(PATH_BACKUP "$ENV{PATH}")
vcpkg_add_to_path("${PERL_EXE_PATH}")
vcpkg_add_to_path("${SED_EXE_PATH}")

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        threads        USE_THREAD
        simplethread   USE_SIMPLE_THREADED_LEVEL3
        "dynamic-arch" DYNAMIC_ARCH
)

set(COMMON_OPTIONS -DBUILD_WITHOUT_LAPACK=ON)

if(VCPKG_TARGET_IS_OSX)
    list(APPEND COMMON_OPTIONS -DONLY_CBLAS=1)
    if("dynamic-arch" IN_LIST FEATURES)
        set(conf_opts GENERATOR "Unix Makefiles")
    endif()
endif()

if(VCPKG_TARGET_IS_ANDROID)
    list(APPEND COMMON_OPTIONS -DONLY_CBLAS=1)
endif()

set(OPENBLAS_EXTRA_OPTIONS)
# For UWP version, must build non-UWP first for helper binaries
if(VCPKG_TARGET_IS_UWP)
    list(APPEND OPENBLAS_EXTRA_OPTIONS "-DBLASHELPER_BINARY_DIR=${CURRENT_HOST_INSTALLED_DIR}/tools/${PORT}")
elseif(NOT (VCPKG_TARGET_IS_WINDOWS AND NOT VCPKG_TARGET_IS_MINGW))
    string(APPEND VCPKG_C_FLAGS " -DNEEDBUNDERSCORE") # Required to get common BLASFUNC to append extra _
    string(APPEND VCPKG_CXX_FLAGS " -DNEEDBUNDERSCORE")
    list(APPEND OPENBLAS_EXTRA_OPTIONS
                -DNOFORTRAN=ON
                -DBU=_  # Required for all BLAS functions to append extra _ using NAME
    )
endif()

if (VCPKG_TARGET_IS_WINDOWS AND VCPKG_TARGET_ARCHITECTURE STREQUAL "arm64")
    list(APPEND OPENBLAS_EXTRA_OPTIONS -DCORE=GENERIC)
endif()

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    ${conf_opts}
    OPTIONS
        ${FEATURE_OPTIONS}
        ${COMMON_OPTIONS}
        ${OPENBLAS_EXTRA_OPTIONS}
)

vcpkg_cmake_install()
vcpkg_copy_pdbs()

vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/OpenBLAS)

if (EXISTS "${CURRENT_PACKAGES_DIR}/bin/getarch${VCPKG_HOST_EXECUTABLE_SUFFIX}")
    vcpkg_copy_tools(TOOL_NAMES getarch AUTO_CLEAN)
endif()
if (EXISTS "${CURRENT_PACKAGES_DIR}/bin/getarch_2nd${VCPKG_HOST_EXECUTABLE_SUFFIX}")
    vcpkg_copy_tools(TOOL_NAMES getarch_2nd AUTO_CLEAN)
endif()

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
# Maybe we need also to write a wrapper inside share/blas to search implicitly for openblas,
# whenever we feel it's ready for its own -config.cmake file.

# openblas does not have a config file, so I manually made this.
# But I think in most cases, libraries will not include these files, they define their own used function prototypes.
# This is only to quite vcpkg.
file(COPY "${CMAKE_CURRENT_LIST_DIR}/openblas_common.h" DESTINATION "${CURRENT_PACKAGES_DIR}/include")

vcpkg_replace_string(
    "${SOURCE_PATH}/cblas.h"
    "#include \"common.h\""
    "#include \"openblas_common.h\""
)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include" "${CURRENT_PACKAGES_DIR}/debug/share")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
