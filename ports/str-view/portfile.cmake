vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO agl-alexglopez/str_view
    REF "v${VERSION}"
    SHA512 97db5e5729fe3cfff9aa9ed6db5f8494847bd11a964d9c0b946cc57c3cdad400b12ad0a6e00133e952164349616ef0f017d537cbc568cd8ee975add68c3f1ee6
    HEAD_REF main
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(
    PACKAGE_NAME "str_view"
    CONFIG_PATH "lib/cmake/str_view"
)

vcpkg_copy_pdbs()
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

if(VCPKG_TARGET_IS_WINDOWS AND VCPKG_LIBRARY_LINKAGE STREQUAL "dynamic")
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/include/str_view/str_view.h" "defined(SV_CONSUME_DLL)" "1")
endif()

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
configure_file("${CMAKE_CURRENT_LIST_DIR}/usage" "${CURRENT_PACKAGES_DIR}/share/${PORT}/usage" COPYONLY)
