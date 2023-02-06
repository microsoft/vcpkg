vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO libimobiledevice/libplist
    REF 52826a6c229ed3e353d4dae711a6c52a96d99764 # v2.2.0-20230205
    SHA512 3eb3012c544c613ce0e2e672d0adba6c4a475a07c62bdc35581e20b3e2f162307e45c460ac76166c135e3d0c5c3ea40aac3ef3497c6816736381fe09547abe4f
    HEAD_REF master
    PATCHES
        fix_windows_build.patch
)

file(COPY "${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt" DESTINATION "${SOURCE_PATH}")

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup()
vcpkg_copy_pdbs()
vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/COPYING")
file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
