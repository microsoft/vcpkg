vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_gitlab(
GITLAB_URL https://gitlab.freedesktop.org/xorg
OUT_SOURCE_PATH SOURCE_PATH
REPO lib/libxpm
REF libXpm-3.5.13
SHA512 250c8bf672789a81cfa258a516d40936f48a56cfaee94bf3f628e3f4a462bdd90eaaea787d66daf09ce4809b89c3eaea1e0771de03a6d7f1a59b31cc82be1c44
)

set(ENV{ACLOCAL} "aclocal -I \"${CURRENT_INSTALLED_DIR}/share/xorg/aclocal/\"")

vcpkg_configure_make(
     SOURCE_PATH "${SOURCE_PATH}"
     AUTOCONFIG
 )

 vcpkg_install_make()


file(INSTALL "${SOURCE_PATH}/COPYRIGHT" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
# file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
