vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO open-source-patterns/collection
    REF "${VERSION}"
    SHA512 f27ba936d09f081cdf604a7f5143eeb6cf64906eda806b0fdfb9a184f1052133275f3d9e84b0d31f81e0ec9db3eb75c835a1f3a941bb4548a9a39534226eb783
    HEAD_REF main
)

vcpkg_cmake_configure(SOURCE_PATH "${SOURCE_PATH}")
vcpkg_cmake_install()

vcpkg_cmake_config_fixup() # removes /debug/share

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include") # removes debug/include
file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}") # usage
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE") # LICENSE
