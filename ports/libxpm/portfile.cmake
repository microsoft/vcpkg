vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_gitlab(
GITLAB_URL https://gitlab.freedesktop.org/xorg
OUT_SOURCE_PATH SOURCE_PATH
REPO lib/libxpm
REF libXpm-3.5.13
SHA512 250c8bf672789a81cfa258a516d40936f48a56cfaee94bf3f628e3f4a462bdd90eaaea787d66daf09ce4809b89c3eaea1e0771de03a6d7f1a59b31cc82be1c44
PATCHES remove_strings_h.patch
)

set(ENV{ACLOCAL} "aclocal -I \"${CURRENT_INSTALLED_DIR}/share/xorg/aclocal/\"")

vcpkg_configure_make(
     SOURCE_PATH "${SOURCE_PATH}"
     AUTOCONFIG
 )

#vcpkg_replace_string("${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg/config.h"
#        "#define STDC_HEADERS 1" "#define STDC_HEADERS 1\n\n#define FOR_MSW 1"
# )

#vcpkg_replace_string("${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/config.h"
#        "#define STDC_HEADERS 1" "#define STDC_HEADERS 1\n\n#define FOR_MSW 1"
# )

vcpkg_install_make()

vcpkg_fixup_pkgconfig(SYSTEM_LIBRARIES pthread)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

# # Handle copyright
file(INSTALL "${SOURCE_PATH}/COPYING" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)

if(VCPKG_LIBRARY_LINKAGE STREQUAL static OR NOT VCPKG_TARGET_IS_WINDOWS)
        file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/bin" "${CURRENT_PACKAGES_DIR}/debug/bin")
endif()