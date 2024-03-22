vcpkg_from_gitlab(
    GITLAB_URL https://gitlab.freedesktop.org/
    OUT_SOURCE_PATH SOURCE_PATH
    REPO libdecor/libdecor
    REF "${VERSION}"
    SHA512 27365c9029caed1064c36490c2007afe5af6ef60c0538a06755be200f122caf444c5dba951fcb954095600469466f75eb75f6f1a642acde065723755a7656a3d
    HEAD_REF master
	PATCHES
		fix-plugin-loading.patch
)

if("gtk" IN_LIST FEATURES)
    list(APPEND OPTIONS -Dgtk=enabled)
else()
    list(APPEND OPTIONS -Dgtk=disabled)
endif()

vcpkg_configure_meson(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS ${OPTIONS}
        -Ddemo=false
        -Ddbus=enabled
)

vcpkg_install_meson()
vcpkg_copy_pdbs()
vcpkg_check_linkage(ONLY_DYNAMIC_LIBRARY)
vcpkg_fixup_pkgconfig()

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
