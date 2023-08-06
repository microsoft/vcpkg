vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_git(
    OUT_SOURCE_PATH SOURCE_PATH
    URL git://www.ginac.de/cln.git
    REF c061316aeebe28770b318c489e779a2d215264c0
    HEAD_REF master
    # PATCHES
    #     fix_cmake_build_error.patch
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
)

vcpkg_cmake_install()
vcpkg_copy_pdbs()

vcpkg_cmake_config_fixup(
    CONFIG_PATH lib/cmake/cln
    TOOLS_PATH tools/${PORT}
)
vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

# if(WIN32)
#     set(_exe_extension_name ".exe")
# else()
#     set(_exe_extension_name "")
# endif()
# file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/tools/${PORT}")
# file(COPY_FILE "${CURRENT_PACKAGES_DIR}/bin/pi${_exe_extension_name}" "${CURRENT_PACKAGES_DIR}/tools/${PORT}/pi${_exe_extension_name}")
# file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/bin")

vcpkg_copy_tools(
    TOOL_NAMES pi
    SEARCH_DIR ${CURRENT_PACKAGES_DIR}/bin
    DESTINATION ${CURRENT_PACKAGES_DIR}/tools/${PORT}
    AUTO_CLEAN
)

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/COPYING")

#file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")