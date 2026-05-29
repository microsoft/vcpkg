vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO ImagingDataCommons/libdicom
    REF "v${VERSION}"
    SHA512 7323616a0beee9954f725daeef255215b337ce56d921ea836262fe3a84ee2eb0cce8d6caf6610c88daea2a9b2d0a1deefb70a750268131f82ad48e66a5a29bdd
    HEAD_REF main
    PATCHES
        cross-build.diff
)
if(VCPKG_CROSSCOMPILING)
    file(COPY
        "${CURRENT_HOST_INSTALLED_DIR}/share/${PORT}/${VERSION}/dicom-dict-lookup.c"
        "${CURRENT_HOST_INSTALLED_DIR}/share/${PORT}/${VERSION}/dicom-dict-lookup.h"
        DESTINATION "${SOURCE_PATH}"
    )
endif()

vcpkg_configure_meson(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -Dtests=false
)
vcpkg_install_meson()
vcpkg_copy_pdbs()
vcpkg_fixup_pkgconfig()

vcpkg_copy_tools(TOOL_NAMES dcm-dump dcm-getframe AUTO_CLEAN)

if(NOT VCPKG_CROSSCOMPILING)
    file(COPY
        "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/dicom-dict-lookup.c"
        "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/dicom-dict-lookup.h"
        DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}/${VERSION}"
    )
endif()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
