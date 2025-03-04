if(VCPKG_TARGET_IS_WINDOWS)
    vcpkg_check_linkage(ONLY_STATIC_LIBRARY)
endif()
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO emilk/loguru
    REF 4adaa185883e3c04da25913579c451d3c32cfac1  #v2.1.0
    SHA512 813c9f9171a828a40270a3ad9f98124586eb56d37f263d55cd1ea6ac997d64431e2ae846f3dc0b477f8bf30873270c53b4bd7e6b6fc52259d2fd36126b24bbe6
    HEAD_REF master
)

vcpkg_check_features(
    OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        fmt LOGURU_USE_FMTLIB
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        ${FEATURE_OPTIONS}
 )

vcpkg_cmake_install()
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
vcpkg_cmake_config_fixup(CONFIG_PATH "lib/cmake/loguru")
vcpkg_copy_pdbs()
vcpkg_fixup_pkgconfig()


vcpkg_install_copyright(FILE_LIST "${CMAKE_CURRENT_LIST_DIR}/copyright")
