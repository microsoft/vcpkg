vcpkg_from_git(
    OUT_SOURCE_PATH SOURCE_PATH
    URL "https://code.videolan.org/videolan/libdvdread.git"
    REF ba2227bb8619724c2bfadcc4d8f25d741a3398ac # 6.1.3
    HEAD_REF master
    PATCHES
        0001-fix-include-missing-on-windows.diff
        0002-fix-uwp.diff
        0003-add-msvc-exports-def.diff
)

file(COPY "${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt" DESTINATION "${SOURCE_PATH}")
file(COPY "${CMAKE_CURRENT_LIST_DIR}/config.h.cm" DESTINATION "${SOURCE_PATH}")
file(COPY "${CMAKE_CURRENT_LIST_DIR}/libdvdread-config.cmake.in" DESTINATION "${SOURCE_PATH}")

vcpkg_cmake_configure(
    SOURCE_PATH ${SOURCE_PATH}
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup()
vcpkg_copy_pdbs()
vcpkg_fixup_pkgconfig()


file(REMOVE_RECURSE
    "${CURRENT_PACKAGES_DIR}/debug/include"
    "${CURRENT_PACKAGES_DIR}/debug/share"
)

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/COPYING")
