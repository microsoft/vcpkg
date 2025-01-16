vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO agl-alexglopez/str_view
    REF "v${VERSION}"
    SHA512 a92c4f5fcfb199e09461cc3e872787dfb79ef1aff237b4a863e016185f42d5902976235c65c29fa632e199ed9a77e2d56a5187c6242e382182e9b0c13ba85bb7
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
