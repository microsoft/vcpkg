## requires AUTOCONF, LIBTOOL and PKCONF
vcpkg_from_gitlab(
    GITLAB_URL https://gitlab.freedesktop.org/xorg
    OUT_SOURCE_PATH SOURCE_PATH
    REPO lib/libxcb-errors
    REF  332f357aa662ad61625ee804f93c5503b2a0c3ec #1.0
    SHA512 e2b1ad74434760b94035ba91a2f43012523f007e82a1c99380be9f08ca8545f31dcfd772cef593c709cef941ff6d8ab421f47b2f3f01ba956cbaa15e4b928b8b
    HEAD_REF master # branch name
    #PATCHES example.patch #patch name
) 
file(TOUCH ${SOURCE_PATH}/m4/dummy)
set(ENV{ACLOCAL} "aclocal -I \"${CURRENT_INSTALLED_DIR}/share/xorg/aclocal/\"")

vcpkg_find_acquire_program(PYTHON3)
get_filename_component(PYTHON3_DIR "${PYTHON3}" DIRECTORY)
vcpkg_add_to_path("${PYTHON3_DIR}")

vcpkg_configure_make(
    SOURCE_PATH ${SOURCE_PATH}
    AUTOCONFIG
    COPY_SOURCE
)

vcpkg_install_make()
vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)

# # Handle copyright
 configure_file("${SOURCE_PATH}/COPYING" "${CURRENT_PACKAGES_DIR}/share/xcb-errors/copyright" COPYONLY)


