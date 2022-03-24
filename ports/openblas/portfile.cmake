vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO xianyi/OpenBLAS
    REF 34ecd967a54f71cb10fb07bf321b2a7597db9d26    # pre-v0.3.20
    SHA512 23ca849014e82add10f21bd5e70e364732364eb2c0f898ca8ff721c1aef927764b0805687ce6bfe5dda440ec5d4f69a591a56bfaada8e82ecf13ef6e3b268236
    HEAD_REF develop
    PATCHES
        uwp.patch
        fix-space-path.patch
        fix-redefinition-function.patch
        fix-uwp-build.patch
        install-tools.patch
)

find_program(GIT NAMES git git.cmd)

# sed and awk are installed with git but in a different directory
get_filename_component(GIT_EXE_PATH "${GIT}" DIRECTORY)
set(SED_EXE_PATH "${GIT_EXE_PATH}/../usr/bin")

# openblas require perl to generate .def for exports
vcpkg_find_acquire_program(PERL)
get_filename_component(PERL_EXE_PATH "${PERL}" DIRECTORY)
set(PATH_BACKUP "$ENV{PATH}")
vcpkg_add_to_path("${PERL_EXE_PATH}")
vcpkg_add_to_path("${SED_EXE_PATH}")

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        threads         USE_THREAD
        simplethread    USE_SIMPLE_THREADED_LEVEL3
        "dynamic-arch"  DYNAMIC_ARCH
)

if(VCPKG_TARGET_IS_OSX)
    if("dynamic-arch" IN_LIST FEATURES)
        vcpkg_check_linkage(ONLY_DYNAMIC_LIBRARY)
        message(STATUS "Openblas with \"dynamic-arch\" option for OSX supports only dynamic linkage. It's not a bag of openblas but bug of combination cmake+ninja+osx. See: https://gitlab.kitware.com/cmake/cmake/-/issues/16731") 
    endif()
endif()

set(OPENBLAS_EXTRA_OPTIONS)
# for UWP version, must build non uwp first for helper
# binaries.
if(VCPKG_TARGET_IS_UWP)    
    list(APPEND OPENBLAS_EXTRA_OPTIONS -DCMAKE_SYSTEM_PROCESSOR=AMD64
                "-DBLASHELPER_BINARY_DIR=${CURRENT_HOST_INSTALLED_DIR}/tools/${PORT}")
elseif(NOT (VCPKG_TARGET_IS_WINDOWS AND NOT VCPKG_TARGET_IS_MINGW))
    string(APPEND VCPKG_C_FLAGS " -DNEEDBUNDERSCORE") # Required to get common BLASFUNC to append extra _
    string(APPEND VCPKG_CXX_FLAGS " -DNEEDBUNDERSCORE")
    list(APPEND OPENBLAS_EXTRA_OPTIONS
                -DBU=_  #required for all blas functions to append extra _ using NAME
    )
endif()

include(vcpkg_find_fortran)
vcpkg_find_fortran(FORTRAN_CMAKE)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        ${FEATURE_OPTIONS}
        ${FORTRAN_CMAKE}
        ${COMMON_OPTIONS}
        ${OPENBLAS_EXTRA_OPTIONS}
)

vcpkg_cmake_install()
vcpkg_copy_pdbs()

vcpkg_cmake_config_fixup(CONFIG_PATH share/cmake/OpenBLAS)

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
#maybe we need also to write a wrapper inside share/blas to search implicitly for openblas, whenever we feel it's ready for its own -config.cmake file

# openblas do not make the config file , so I manually made this
# but I think in most case, libraries will not include these files, they define their own used function prototypes
# this is only to quite vcpkg
file(COPY "${CMAKE_CURRENT_LIST_DIR}/openblas_common.h" DESTINATION "${CURRENT_PACKAGES_DIR}/include")

vcpkg_replace_string(
    "${SOURCE_PATH}/cblas.h"
    "#include \"common.h\""
    "#include \"openblas_common.h\""
)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include" "${CURRENT_PACKAGES_DIR}/debug/share")

file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
