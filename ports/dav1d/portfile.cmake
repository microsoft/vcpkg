vcpkg_fail_port_install(ON_ARCH "arm" "x86" ON_TARGET "uwp")

vcpkg_from_gitlab(
    GITLAB_URL https://code.videolan.org
    OUT_SOURCE_PATH SOURCE_PATH
    REPO videolan/dav1d
    REF 0.8.1
    SHA512 dd40b82b65e4be37a27ab11e7116f7a244b0da4469915ead3922ac31724fb6da3910a78629a32a669031fe08d4323ab135174afb7462f6ea4adf96c111841c1c
    PATCHES
        "patch_underscore_prefix.patch"
)

vcpkg_find_acquire_program(NASM)
get_filename_component(NASM_EXE_PATH ${NASM} DIRECTORY)
vcpkg_add_to_path(${NASM_EXE_PATH})

set(LIBRARY_TYPE ${VCPKG_LIBRARY_LINKAGE})
if (LIBRARY_TYPE STREQUAL "dynamic")
    set(LIBRARY_TYPE "shared")
endif(LIBRARY_TYPE STREQUAL "dynamic")

vcpkg_configure_meson(
    SOURCE_PATH ${SOURCE_PATH}
    OPTIONS
        --default-library=${LIBRARY_TYPE}
        -Denable_tests=false
        -Denable_tools=false
)

vcpkg_install_meson()
vcpkg_copy_pdbs()

configure_file("${SOURCE_PATH}/COPYING" "${CURRENT_PACKAGES_DIR}/share/${PORT}/copyright" COPYONLY)
