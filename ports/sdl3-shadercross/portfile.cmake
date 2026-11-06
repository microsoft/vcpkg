vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO libsdl-org/SDL_shadercross
    REF 1ca46e0ef7a9e50c706e7be6ef73ce467bac3b2e
    SHA512 61feb70137b1a8e9037b0f9113a28b1f59578d6604423ef2a66173d9772b15a001f661cb4b53b0f3be941c0178d3562b0ae4d7a7f35404b137204bdce95f537f
    HEAD_REF main
    PATCHES
        fix-directx-shader-compiler-includes.patch
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DSDLSHADERCROSS_INSTALL=ON
        -DSDLSHADERCROSS_INSTALL_CMAKEDIR_ROOT=share/sdl3_shadercross
        -DSDLSHADERCROSS_INSTALL_RUNTIME=OFF
        -DSDLSHADERCROSS_SPIRVCROSS_SHARED=OFF
        -DSDLSHADERCROSS_VENDORED=OFF
)

vcpkg_cmake_install()
if (VCPKG_TARGET_IS_WINDOWS)
    vcpkg_cmake_config_fixup(PACKAGE_NAME "sdl3_shadercross")
else()
    vcpkg_cmake_config_fixup(PACKAGE_NAME "sdl3_shadercross" CONFIG_PATH "share/sdl3_shadercross/SDL3_shadercross")
endif()

file(REMOVE_RECURSE
    "${CURRENT_PACKAGES_DIR}/debug/include"
    "${CURRENT_PACKAGES_DIR}/debug/share"
)

vcpkg_copy_pdbs()
vcpkg_fixup_pkgconfig()

vcpkg_copy_tools(TOOL_NAMES shadercross AUTO_CLEAN)

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE.txt")
