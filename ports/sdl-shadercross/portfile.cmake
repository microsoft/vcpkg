vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO libsdl-org/SDL_shadercross
    REF e1000de7d174af8f84935db9a59b365d1ae55d32
    SHA512 ef0a167fdc9f4903719132f4d4108d286fe29f0773788730106cc2b41fa551d0920f9fc332e2c17b1aed2442a04d4abf84983a36c456191a5f7bb7e8c1cf9f8d
    HEAD_REF main
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DSDLSHADERCROSS_SPIRVCROSS_SHARED=OFF
        -DSDLSHADERCROSS_INSTALL=ON
        -DSDLSHADERCROSS_INSTALL_CMAKEDIR_ROOT=share/${PORT}
)

vcpkg_cmake_install()

set(config_path "share/${PORT}/SDL3_shadercross")
if(VCPKG_TARGET_IS_WINDOWS AND NOT VCPKG_TARGET_IS_MINGW)
    set(config_path "share/${PORT}")
endif()
vcpkg_cmake_config_fixup(CONFIG_PATH "${config_path}")

file(REMOVE_RECURSE
    "${CURRENT_PACKAGES_DIR}/debug/include"
    "${CURRENT_PACKAGES_DIR}/debug/share"
)

vcpkg_copy_pdbs()
vcpkg_fixup_pkgconfig()

vcpkg_copy_tools(TOOL_NAMES shadercross AUTO_CLEAN)

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE.txt")
