vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO libsdl-org/SDL_shadercross
    REF 7b7365a86611b2a7b6462e521cf1c43a037d0970
    SHA512 52efd2c2507d6ae874cdc177945e15494920f11148e9e9cf8da27fb5ccacb5fcbe44581005e132a84631e9d438616aa1247b7ae23f4ef1785203cdcb08af19af
    HEAD_REF main
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DSDLSHADERCROSS_INSTALL=ON
        -DSDLSHADERCROSS_INSTALL_CMAKEDIR_ROOT=share/sdl3_shadercross
        -DSDLSHADERCROSS_INSTALL_RUNTIME=OFF
        -DSDLSHADERCROSS_SPIRVCROSS_SHARED=OFF
        -DSDLSHADERCROSS_VENDORED=OFF
        -DDirectXShaderCompiler_INCLUDE_PATH=${CURRENT_INSTALLED_DIR}/include/directx-dxc
)

vcpkg_cmake_install()
vcpkg_copy_pdbs()
vcpkg_fixup_pkgconfig()

vcpkg_cmake_config_fixup(PACKAGE_NAME "sdl3_shadercross")

vcpkg_copy_tools(TOOL_NAMES shadercross AUTO_CLEAN)

file(REMOVE_RECURSE
    "${CURRENT_PACKAGES_DIR}/debug/include"
    "${CURRENT_PACKAGES_DIR}/debug/share"
)

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE.txt")
