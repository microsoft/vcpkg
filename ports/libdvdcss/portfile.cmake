vcpkg_from_git(
    OUT_SOURCE_PATH SOURCE_PATH
    URL "https://code.videolan.org/videolan/libdvdcss.git"
    REF d0b6a291c24eda3727ad5c7a14956fc1fc82446d # 1.4.2
    HEAD_REF master
    PATCHES
        0001-fix-uwp.diff
        0002-add-msvc-exports-def.diff
)

file(COPY "${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt" DESTINATION "${SOURCE_PATH}")
file(COPY "${CMAKE_CURRENT_LIST_DIR}/config.h.cm" DESTINATION "${SOURCE_PATH}")
file(COPY "${CMAKE_CURRENT_LIST_DIR}/libdvdcss-config.cmake.in" DESTINATION "${SOURCE_PATH}")

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
