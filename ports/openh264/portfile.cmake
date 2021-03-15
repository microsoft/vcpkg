vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO cisco/openh264
    REF f15f940425eebf24ce66984db2445733cf500b7b
    SHA512 361003296e9cef2956aeff76ae4df7a949a585710facd84a92c1b4164c5a4522d6615fcc485ebc2e50be8a13feb942b870efdd28837307467081cb1eba1f17d2
)

# NASM.
if ((VCPKG_TARGET_ARCHITECTURE STREQUAL "x86" OR VCPKG_TARGET_ARCHITECTURE STREQUAL "x64"))
    vcpkg_find_acquire_program(NASM)
    get_filename_component(NASM_EXE_PATH ${NASM} DIRECTORY)
    vcpkg_add_to_path(${NASM_EXE_PATH})
endif()

# Gas.
if ((VCPKG_TARGET_ARCHITECTURE STREQUAL "arm" OR VCPKG_TARGET_ARCHITECTURE STREQUAL "arm64") AND VCPKG_TARGET_IS_WINDOWS)
    vcpkg_find_acquire_program(GASPREPROCESSOR)
    get_filename_component(GASPREPROCESSOR_EXE_PATH ${GASPREPROCESSOR} DIRECTORY)
    vcpkg_add_to_path(${GASPREPROCESSOR_EXE_PATH})
endif()

vcpkg_configure_meson(
    SOURCE_PATH ${SOURCE_PATH})

vcpkg_install_meson()
vcpkg_copy_pdbs()

configure_file("${SOURCE_PATH}/LICENSE" "${CURRENT_PACKAGES_DIR}/share/${PORT}/copyright" COPYONLY)
