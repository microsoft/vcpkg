vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO ImagingDataCommons/libdicom
    REF "v${VERSION}"
    SHA512 060c640b8ea4730ec24ed0d576f86ced354af63b752ff893e7327eb715f34a3fbafe223be6e8a76b81ed79014005644aff78aeed100ea5d39b4338d330740cda
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
