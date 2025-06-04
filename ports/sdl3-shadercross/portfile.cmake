vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO libsdl-org/SDL_shadercross
    REF 7c1c545fb2e2bc12b80c85ec49be3500dc751b20
    SHA512 ebaf9ea18522f6224e36b087d8963de527250ef698c0c5f222ff0e6ae598a992b5bc317ca5af8d4f9124c2536a5ec6e6e6d720eb5c511bdc05f7a69f1f05cba7
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
