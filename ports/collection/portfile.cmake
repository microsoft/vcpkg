vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO open-source-patterns/collection
    REF "${VERSION}"
    SHA512 45cc0fe317d105d1d9e5704720f783e9db765468c280c3e5b07d0defacf96fd1401fe4591e7c4421211bc2310f7e1899b58324e080742c50098ee0642430ab8d
    HEAD_REF main
)

vcpkg_cmake_configure(SOURCE_PATH "${SOURCE_PATH}")
vcpkg_cmake_install()

vcpkg_cmake_config_fixup() # removes /debug/share

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include") # removes debug/include
file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}") # usage
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE") # LICENSE
