vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO libass/libass
    REF ${VERSION}
    SHA512 08762623dd09e3034699ba9d11b70d1f6cc6b2e3b38aa897b07efef1364e76141df484e70ed27888cf3595b77d072cdb5e8abbbfa560e33ca21f87872e24df8d
    HEAD_REF master
    PATCHES
        arm64-windows-asm.patch
)

vcpkg_find_acquire_program(PKGCONFIG)
get_filename_component(PKGCONFIG_EXE_PATH ${PKGCONFIG} DIRECTORY)
vcpkg_add_to_path(${PKGCONFIG_EXE_PATH})

list(APPEND options
    -Dcheckasm=disabled
    -Dcompare=disabled
    -Dfuzz=disabled
    -Dprofile=disabled
    -Dtest=disabled
)

if(NOT VCPKG_TARGET_IS_WINDOWS AND NOT VCPKG_TARGET_IS_OSX AND NOT VCPKG_TARGET_IS_LINUX)
    list(APPEND options -Drequire-system-font-provider=false)
endif()

set(asm_option disabled)
set(additional_binaries "")
if(VCPKG_TARGET_ARCHITECTURE MATCHES "^(x86|x64|arm64)$")
    set(asm_option enabled)
    if(VCPKG_TARGET_ARCHITECTURE MATCHES "^(x86|x64)$")
        vcpkg_find_acquire_program(NASM)
        get_filename_component(NASM_EXE_PATH "${NASM}" DIRECTORY)
        vcpkg_add_to_path("${NASM_EXE_PATH}")
    elseif(VCPKG_TARGET_IS_WINDOWS AND VCPKG_TARGET_ARCHITECTURE STREQUAL "arm64")
        vcpkg_find_acquire_program(CLANG)
        list(APPEND additional_binaries "clang = ['${CLANG}']")
    endif()
else()
    message(WARNING "Assembly optimizations are not supported on ${VCPKG_TARGET_ARCHITECTURE}; disabling assembly optimizations.")
endif()
list(APPEND options -Dasm=${asm_option})

vcpkg_configure_meson(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        ${options}
    ADDITIONAL_BINARIES
        ${additional_binaries}
)

vcpkg_install_meson()
vcpkg_copy_pdbs()
vcpkg_fixup_pkgconfig()

# Handle copyright
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/COPYING")
