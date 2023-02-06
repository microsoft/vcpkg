vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO libimobiledevice/libusbmuxd
    REF 6426362e5cbad7284368b7fe70363f6b3251f94c # v2.0.2-20220905
    SHA512 cd37196f5de9411eee02b3407eabb13a4139c214c825a1044d20b34e527a4d5c64db5a85b832f401b7bd16e772115c7044d375f1a6ddfb6209b539e21f06aae6
    HEAD_REF master
)

file(COPY "${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt" DESTINATION "${SOURCE_PATH}")

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup()
vcpkg_copy_pdbs()
vcpkg_fixup_pkgconfig()
vcpkg_copy_tools(TOOL_NAMES iproxy inetcat AUTO_CLEAN)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/COPYING")
file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
