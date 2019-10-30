#.rst:
# .. command:: vcpkg_fixup_pkgconfig_targets
#
#  Transforms all references matching /packages/<port>_<triplet>/ to /installed/<triplet>/
#
#  ::
#  vcpkg_fixup_pkgconfig_targets()
#
#	Example usage:
# 		vcpkg_fixup_pkgconfig_targets()

function(vcpkg_fixup_pkgconfig_targets)
    set(PKGCONFIG_FILES ${CURRENT_PACKAGES_DIR})

    file(GLOB_RECURSE PKGCONFIG_FILES ${CURRENT_PACKAGES_DIR} *.pc)

    foreach(PKGCONFIG_FILE IN LISTS PKGCONFIG_FILES)
        file(READ ${PKGCONFIG_FILE} _contents)
        string(REPLACE "packages/${PORT}_${TARGET_TRIPLET}" "installed/${TARGET_TRIPLET}" _contents "${_contents}")
        file(WRITE ${PKGCONFIG_FILE} "${_contents}")
    endforeach()

endfunction()
