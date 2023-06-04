vcpkg_minimum_required(VERSION 2022-10-12) # for ${VERSION}

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO libharu/libharu
    REF v${VERSION}
    SHA512 4b01dd0d23bdcaec6f69fe5f059902e7f49eafdf19d53d4cce8b4d52a54b2057b764de29390f4da9e75aeb32cb6af8606b23478b04edf9f7dcb1e4b769c5fff2
    HEAD_REF master
    PATCHES
        fix-include-path.patch
        export-targets.patch
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(PACKAGE_NAME unofficial-libharu)

file(REMOVE_RECURSE
    "${CURRENT_PACKAGES_DIR}/debug/include"
    "${CURRENT_PACKAGES_DIR}/debug/share"
    "${CURRENT_PACKAGES_DIR}/debug/README.md"
    "${CURRENT_PACKAGES_DIR}/debug/CHANGES"
    "${CURRENT_PACKAGES_DIR}/debug/INSTALL"
    "${CURRENT_PACKAGES_DIR}/README.md"
    "${CURRENT_PACKAGES_DIR}/CHANGES"
    "${CURRENT_PACKAGES_DIR}/INSTALL"
)

if(VCPKG_TARGET_IS_WINDOWS AND VCPKG_LIBRARY_LINKAGE STREQUAL "dynamic")
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/include/hpdf.h" "#ifdef HPDF_DLL\n" "#if 1\n")
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/include/hpdf_types.h" "#ifdef HPDF_DLL\n" "#if 1\n")
endif()

vcpkg_copy_pdbs()
file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")

vcpkg_install_copyright(FILE_LIST ${SOURCE_PATH}/LICENSE)
