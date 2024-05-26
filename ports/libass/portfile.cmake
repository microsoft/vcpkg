vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO libass/libass
    REF 0.17.2
    SHA512 a3e6d514c618a3d2a78287060a6de8002d926b606805a9306f41b902b382f221eff5a7276516c9b4dbe48fa2462936ec7a99585b2615fd44c6564c121ec4cb62
    HEAD_REF master
)

vcpkg_find_acquire_program(PKGCONFIG)
get_filename_component(PKGCONFIG_EXE_PATH ${PKGCONFIG} DIRECTORY)
vcpkg_add_to_path(${PKGCONFIG_EXE_PATH})

if("asm" IN_LIST FEATURES)
    list(APPEND FEATURE_OPTIONS -Dasm=enabled)
    vcpkg_find_acquire_program(NASM)
    get_filename_component(NASM_EXE_PATH ${NASM} DIRECTORY)
    vcpkg_add_to_path(${NASM_EXE_PATH})
endif()

vcpkg_configure_meson(
    SOURCE_PATH ${SOURCE_PATH}
    OPTIONS ${FEATURE_OPTIONS}
)

vcpkg_install_meson()
vcpkg_copy_pdbs()
vcpkg_fixup_pkgconfig()

# Handle copyright
file(INSTALL ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
