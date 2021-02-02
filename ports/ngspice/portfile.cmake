vcpkg_fail_port_install(ON_TARGET "Linux" "OSX" "UWP" ON_ARCH "arm" "arm64")

vcpkg_check_linkage(ONLY_DYNAMIC_LIBRARY)

# ngspice produces self-contained DLLs
set(VCPKG_CRT_LINKAGE static)

vcpkg_from_sourceforge(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO ngspice/ng-spice-rework
    REF 33
    FILENAME "ngspice-33.tar.gz"
    SHA512 895e39f7de185df18bf443a9fa5691cdb3bf0a5091d9860d20ccb02254ef396a4cca5a1c8bf4ba19a03783fc89bb86649218cee977b0fe4565d3c84548943c09
    PATCHES
        use-winbison-sharedspice.patch
        use-winbison-vngspice.patch
)

vcpkg_find_acquire_program(BISON)

get_filename_component(BISON_DIR "${BISON}" DIRECTORY)
vcpkg_add_to_path(PREPEND "${BISON_DIR}")

# Sadly, vcpkg globs .libs inside install_msbuild and whines that the 47 year old SPICE format isn't a MSVC lib ;)
# We need to kill them off first before the source tree is copied to a tmp location by install_msbuild

file(REMOVE_RECURSE ${SOURCE_PATH}/contrib)
file(REMOVE_RECURSE ${SOURCE_PATH}/examples)
file(REMOVE_RECURSE ${SOURCE_PATH}/man)
file(REMOVE_RECURSE ${SOURCE_PATH}/tests)

# this builds the main dll
vcpkg_install_msbuild(
    SOURCE_PATH ${SOURCE_PATH}
    INCLUDES_SUBPATH /src/include
    LICENSE_SUBPATH COPYING
    # install_msbuild swaps x86 for win32(bad) if we dont force our own setting
    PLATFORM ${TRIPLET_SYSTEM_ARCH}
    PROJECT_SUBPATH visualc/sharedspice.sln
    TARGET Build
)

if("codemodels" IN_LIST FEATURES)
    # vngspice generates "codemodels" to enhance simulation capabilities
    # we cannot use install_msbuild as they output with ".cm" extensions on purpose
    set(BUILDTREE_PATH ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET})
    file(REMOVE_RECURSE ${BUILDTREE_PATH})
    file(COPY ${SOURCE_PATH}/ DESTINATION ${BUILDTREE_PATH})

    vcpkg_build_msbuild(
        PROJECT_PATH ${BUILDTREE_PATH}/visualc/vngspice.sln
        INCLUDES_SUBPATH /src/include
        LICENSE_SUBPATH COPYING
        # build_msbuild swaps x86 for win32(bad) if we dont force our own setting
        PLATFORM ${TRIPLET_SYSTEM_ARCH}
        TARGET Build
    )
    
    #put the code models in the intended location
    file(GLOB NGSPICE_CODEMODELS_DEBUG
        ${BUILDTREE_PATH}/visualc/codemodels/${TRIPLET_SYSTEM_ARCH}/Debug/*.cm
    )
    file(COPY ${NGSPICE_CODEMODELS_DEBUG} DESTINATION ${CURRENT_PACKAGES_DIR}/debug/lib/ngspice)
    
    file(GLOB NGSPICE_CODEMODELS_RELEASE
        ${BUILDTREE_PATH}/visualc/codemodels/${TRIPLET_SYSTEM_ARCH}/Release/*.cm
    )
    file(COPY ${NGSPICE_CODEMODELS_RELEASE} DESTINATION ${CURRENT_PACKAGES_DIR}/lib/ngspice)
    
    
    # copy over spinit (spice init)
    file(RENAME ${BUILDTREE_PATH}/visualc/spinit_all ${BUILDTREE_PATH}/visualc/spinit)
    file(COPY ${BUILDTREE_PATH}/visualc/spinit DESTINATION ${CURRENT_PACKAGES_DIR}/share/ngspice)
endif()

vcpkg_copy_pdbs()

# Unforunately install_msbuild isn't able to dual include directories that effectively layer
file(GLOB NGSPICE_INCLUDES ${SOURCE_PATH}/visualc/src/include/ngspice/*)
file(COPY ${NGSPICE_INCLUDES} DESTINATION ${CURRENT_PACKAGES_DIR}/include/ngspice)
