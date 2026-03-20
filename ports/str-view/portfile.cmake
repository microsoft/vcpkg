vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO agl-alexglopez/str_view
    REF "v${VERSION}"
    SHA512 2ccdfd31948b15d5704faffb52a85fce4cb72c5cdb881b4ad097b06b6a584d74c3062887a5b6d43e60d793a4261708047af0d65960bf86f994fdd7d79fa253d0
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
