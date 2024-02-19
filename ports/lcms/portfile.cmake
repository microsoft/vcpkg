if(VCPKG_LIBRARY_LINKAGE STREQUAL "dynamic")
    set(SHARED_LIBRARY_PATCH "fix-shared-library.patch")
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO mm2/Little-CMS
    REF "lcms${VERSION}"
    SHA512 c0d857123a0168cb76b5944a20c9e3de1cbe74e2b509fb72a54f74543e9c173474f09d50c495b0a0a295a3c2b47c5fa54a330d057e1a59b5a7e36d3f5a7f81b2
    HEAD_REF master
    PATCHES
        fix-builderror.patch # Upstream commit: https://github.com/mm2/Little-CMS/commit/f7b3c637c20508655f8b49935a4b556d52937b69
        ${SHARED_LIBRARY_PATCH} #Issue https://github.com/microsoft/vcpkg/issues/1665
)

vcpkg_configure_meson(
    SOURCE_PATH "${SOURCE_PATH}"
)

vcpkg_install_meson()

vcpkg_copy_pdbs()
vcpkg_fixup_pkgconfig()

configure_file("${CMAKE_CURRENT_LIST_DIR}/unofficial-lcms2-config.cmake.in" "${CURRENT_PACKAGES_DIR}/share/lcms2/lcms2-config.cmake" @ONLY)
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
