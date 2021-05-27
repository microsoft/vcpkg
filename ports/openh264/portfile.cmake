vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO cisco/openh264
    REF f15f940425eebf24ce66984db2445733cf500b7b
    SHA512 361003296e9cef2956aeff76ae4df7a949a585710facd84a92c1b4164c5a4522d6615fcc485ebc2e50be8a13feb942b870efdd28837307467081cb1eba1f17d2
    PATCHES
        0001-respect-default-library-option.patch  # https://github.com/cisco/openh264/pull/3351
)

if((VCPKG_TARGET_ARCHITECTURE STREQUAL "x86" OR VCPKG_TARGET_ARCHITECTURE STREQUAL "x64"))
    vcpkg_find_acquire_program(NASM)
    get_filename_component(NASM_EXE_PATH ${NASM} DIRECTORY)
    vcpkg_add_to_path(${NASM_EXE_PATH})
elseif(VCPKG_TARGET_IS_WINDOWS)
    vcpkg_find_acquire_program(GASPREPROCESSOR)
    foreach(GAS_PATH ${GASPREPROCESSOR})
        get_filename_component(GAS_ITEM_PATH ${GAS_PATH} DIRECTORY)
        vcpkg_add_to_path(${GAS_ITEM_PATH})
    endforeach(GAS_PATH)
endif()

vcpkg_configure_meson(
    SOURCE_PATH ${SOURCE_PATH}
    OPTIONS -Dtests=disabled
)

vcpkg_install_meson()
vcpkg_copy_pdbs()
vcpkg_fixup_pkgconfig()

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/bin" "${CURRENT_PACKAGES_DIR}/debug/bin")
endif()

configure_file("${SOURCE_PATH}/LICENSE" "${CURRENT_PACKAGES_DIR}/share/${PORT}/copyright" COPYONLY)
