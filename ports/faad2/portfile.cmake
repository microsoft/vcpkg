vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO knik0/faad2
    REF "${VERSION}"
    SHA512 fd140c0f4e7946e95a49a8652e26f33b138fc3375da34d5e3a55cdde8a74be429eb6fe0180bd434841022cee3c2ec65fe40dda7440fe0dd2761622174f992490
    HEAD_REF master
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
)

vcpkg_cmake_install()

vcpkg_copy_pdbs()
vcpkg_fixup_pkgconfig()

if(VCPKG_TARGET_IS_WINDOWS)
    vcpkg_copy_tools(TOOL_NAMES faad_cli AUTO_CLEAN)
else()
    vcpkg_copy_tools(TOOL_NAMES faad AUTO_CLEAN)
endif()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/COPYING")
