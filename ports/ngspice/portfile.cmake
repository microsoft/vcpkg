vcpkg_check_linkage(ONLY_DYNAMIC_LIBRARY)

# ngspice produces self-contained DLLs
set(VCPKG_CRT_LINKAGE static)

vcpkg_from_sourceforge(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO ngspice/ng-spice-rework
    REF ${VERSION}
    FILENAME "ngspice-${VERSION}.tar.gz"
    SHA512 fb0960cc9fcde1871fad82571cacebb1f5cce09ee3297cc938a24b88173ed102a2cb3f246599cdfbde7275e45e3d551edd0368e3ba6e79c592937c4cc466325e
    PATCHES
        use-winbison-sharedspice.patch
        use-winbison-vngspice.patch
        remove-post-build.patch
        remove-64-in-codemodel-name.patch
        Fix-C2065.patch
)

vcpkg_find_acquire_program(BISON)

get_filename_component(BISON_DIR "${BISON}" DIRECTORY)
vcpkg_add_to_path(PREPEND "${BISON_DIR}")

# Sadly, vcpkg globs .libs inside install_msbuild and whines that the 47 year old SPICE format isn't a MSVC lib ;)
# We need to kill them off first before the source tree is copied to a tmp location by install_msbuild

file(REMOVE_RECURSE "${SOURCE_PATH}/contrib")
file(REMOVE_RECURSE "${SOURCE_PATH}/examples")
file(REMOVE_RECURSE "${SOURCE_PATH}/man")
file(REMOVE_RECURSE "${SOURCE_PATH}/tests")

# this builds the main dll
vcpkg_msbuild_install(
    SOURCE_PATH "${SOURCE_PATH}"
    # install_msbuild swaps x86 for win32(bad) if we dont force our own setting
    PLATFORM ${TRIPLET_SYSTEM_ARCH}
    PROJECT_SUBPATH visualc/sharedspice.sln
    TARGET Build
)

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/COPYING")
file(COPY "${SOURCE_PATH}/src/include/" DESTINATION "${CURRENT_PACKAGES_DIR}/include")

if("codemodels" IN_LIST FEATURES)
    # vngspice generates "codemodels" to enhance simulation capabilities
    # we cannot use install_msbuild as they output with ".cm" extensions on purpose
    vcpkg_msbuild_install(
        SOURCE_PATH "${SOURCE_PATH}"
        PROJECT_SUBPATH visualc/vngspice.sln
        # build_msbuild swaps x86 for win32(bad) if we dont force our own setting
        PLATFORM ${TRIPLET_SYSTEM_ARCH}
        TARGET Build
    )

    # ngspice oddly has solution configs of x64 and x86 but
    # output folders of x64 and win32
    if(VCPKG_TARGET_ARCHITECTURE STREQUAL x64)
        set(OUT_ARCH  x64)
    elseif(VCPKG_TARGET_ARCHITECTURE STREQUAL x86)
        set(OUT_ARCH  Win32)
    else()
        message(FATAL_ERROR "Unsupported target architecture")
    endif()

    #put the code models in the intended location
    if(NOT VCPKG_BUILD_TYPE)
      file(GLOB NGSPICE_CODEMODELS_DEBUG
          "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg/visualc/codemodels/${OUT_ARCH}/Debug/*.cm"
      )
      file(COPY ${NGSPICE_CODEMODELS_DEBUG} DESTINATION "${CURRENT_PACKAGES_DIR}/debug/lib/ngspice")
    endif()

    file(GLOB NGSPICE_CODEMODELS_RELEASE
        "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/visualc/codemodels/${OUT_ARCH}/Release/*.cm"
    )
    file(COPY ${NGSPICE_CODEMODELS_RELEASE} DESTINATION "${CURRENT_PACKAGES_DIR}/lib/ngspice")

    # copy over spinit (spice init)
    file(COPY "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/visualc/spinit_all" DESTINATION "${CURRENT_PACKAGES_DIR}/share/ngspice")
    file(RENAME "${CURRENT_PACKAGES_DIR}/share/ngspice/spinit_all" "${CURRENT_PACKAGES_DIR}/share/ngspice/spinit")
endif()

# Unforunately install_msbuild isn't able to dual include directories that effectively layer
file(GLOB NGSPICE_INCLUDES "${SOURCE_PATH}/visualc/src/include/ngspice/*")
file(COPY ${NGSPICE_INCLUDES} DESTINATION "${CURRENT_PACKAGES_DIR}/include/ngspice")

# This gets copied by install_msbuild but should not be shared
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/include/cppduals")
