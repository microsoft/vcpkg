vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO libass/libass
    REF 0.15.1
    SHA512 eadda1dcdeb15be8cecbb14ad922eb3f366a780d82376d257c799424a0296b4d7539e86f12234e8c1480bdea423d9dbb78644b18970f65b8f5af5d0ef49c5fc9
    HEAD_REF master
    PATCHES
      enable-asm-with-msvc-compiler.patch
)

file(COPY ${CMAKE_CURRENT_LIST_DIR}/libass/ass/meson.build DESTINATION ${SOURCE_PATH}/libass/ass)
file(COPY ${CMAKE_CURRENT_LIST_DIR}/libass/profile/meson.build DESTINATION ${SOURCE_PATH}/libass/profile)
file(COPY ${CMAKE_CURRENT_LIST_DIR}/libass/test/meson.build DESTINATION ${SOURCE_PATH}/libass/test)
file(COPY ${CMAKE_CURRENT_LIST_DIR}/libass/meson.build DESTINATION ${SOURCE_PATH}/libass)
file(COPY ${CMAKE_CURRENT_LIST_DIR}/libass.def DESTINATION ${SOURCE_PATH}/libass)
file(COPY ${CMAKE_CURRENT_LIST_DIR}/meson.build DESTINATION ${SOURCE_PATH})
file(COPY ${CMAKE_CURRENT_LIST_DIR}/meson_options.txt DESTINATION ${SOURCE_PATH})

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
