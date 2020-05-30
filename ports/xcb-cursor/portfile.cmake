vcpkg_from_gitlab(
    GITLAB_URL https://gitlab.freedesktop.org/xorg
    OUT_SOURCE_PATH SOURCE_PATH
    REPO lib/libxcb-cursor
    REF  95b9a8fd876fdbbc854cdf3d90317be3846c7417 #0.1.3
    SHA512 cca7bf1f2aeaab8d256052a676098d7c600b90dc47cf9bc84d11229e59fbf5c83f7f877b8538f7cc662983807566d28c87b3501abc7cab76cc553d9db29eceb9
    HEAD_REF master # branch name
    #PATCHES example.patch #patch name
) 

vcpkg_find_acquire_program(GPERF)
get_filename_component(GPERF_DIR "${GPERF}" DIRECTORY)
vcpkg_add_to_path("${GPERF_DIR}")

set(ENV{ACLOCAL} "aclocal -I \"${CURRENT_INSTALLED_DIR}/share/xorg/aclocal/\"")

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
file(COPY "${SOURCE_PATH}/COPYING" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
