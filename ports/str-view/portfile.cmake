vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO agl-alexglopez/str_view
    REF "v${VERSION}"
    SHA512 cf10875a602bf01bbbaa62d450e7219e91d9594898d604e06a25a0a77087bc30522518e521aa3f63e87bbf610eb5d906f8dd741aa03f48a7f03682c96937754a
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
