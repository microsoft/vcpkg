vcpkg_fail_port_install(ON_TARGET "Linux" "OSX" "UWP" ON_ARCH "arm" "arm64")

vcpkg_check_linkage(ONLY_DYNAMIC_LIBRARY)

# ngspice produces self-contained DLLs
set(VCPKG_CRT_LINKAGE static)

vcpkg_from_sourceforge(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO ngspice/ng-spice-rework
    REF 32
    FILENAME "ngspice-32.tar.gz"
    SHA512 222eaa0cd6577a6eb8454bb49a7050a162d430c4b07a4fdc6baf350c5b3f5b018bac640fd44f465ec09c8cba6a9729b1cbe8d3d8c097f672acc2c22fabe8f4bc
    PATCHES
        use-winbison-global.patch
)

vcpkg_find_acquire_program(BISON)

get_filename_component(BISON_DIR "${BISON}" DIRECTORY)
vcpkg_add_to_path(PREPEND "${BISON_DIR}")

# Ensure its windows
if (VCPKG_TARGET_IS_WINDOWS)
    # Sadly, vcpkg globs .libs inside install_msbuild and whines that the 47 year old SPICE format isn't a MSVC lib ;)
    # We need to kill them off first before the source tree is copied to a tmp location by install_msbuild

    file(REMOVE_RECURSE ${SOURCE_PATH}/contrib)
    file(REMOVE_RECURSE ${SOURCE_PATH}/examples)
    file(REMOVE_RECURSE ${SOURCE_PATH}/man)
    file(REMOVE_RECURSE ${SOURCE_PATH}/tests)

    vcpkg_install_msbuild(
        SOURCE_PATH ${SOURCE_PATH}
        INCLUDES_SUBPATH /src/include
        LICENSE_SUBPATH COPYING
        # install_msbuild swaps x86 for win32(bad) if we dont force our own setting
        PLATFORM ${TRIPLET_SYSTEM_ARCH}
        PROJECT_SUBPATH visualc/sharedspice.sln
        TARGET Build
    )
else()
    message(FATAL_ERROR "Sorry but ngspice only can be built in Windows")
endif()

# Unforunately install_msbuild isn't able to dual include directories that effectively layer
file(GLOB NGSPICE_INCLUDES
    ${SOURCE_PATH}/visualc/src/include/ngspice/*
)
file(COPY ${NGSPICE_INCLUDES} DESTINATION ${CURRENT_PACKAGES_DIR}/include/ngspice)

vcpkg_copy_pdbs()
