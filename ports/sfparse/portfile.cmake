vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO ngtcp2/sfparse
    REF 4b313cfd2e1b389ae632b36dcd50402307289af2
    SHA512 cf5e7ac12af29c7ff77247b71d74e9b109444fd61a52f8b44c4421eb48e23865aba3618371f658d362740df92a21657b5e1298cea1e5685f24dbd7ed3b9ca5d1
    HEAD_REF main
    PATCHES
        001-fix-exports.patch
)

file(COPY "${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt" DESTINATION "${SOURCE_PATH}/")

vcpkg_cmake_configure(SOURCE_PATH "${SOURCE_PATH}")
vcpkg_cmake_install()
vcpkg_copy_pdbs()
vcpkg_cmake_config_fixup(PACKAGE_NAME unofficial-${PORT})

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/include/sfparse/sfparse.h" "defined(SFPARSE_STATIC)" "1")
endif()

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/COPYING")
