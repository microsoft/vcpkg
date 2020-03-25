
vcpkg_from_gitlab(
    GITLAB_URL https://gitlab.freedesktop.org
    OUT_SOURCE_PATH SOURCE_PATH
    REPO mesa/drm
    REF  0190f49a139e7069d7cad6a6890832831da1aa8b #v2.4.100 
    SHA512 2d1d372e3f5007a6286f5e95f455af32dd678f04fa47629b7ddc461423120ae424e783985fa33c72bfd4ffc7d1c079a84f2f44bb3888b3d5e9eea458bb36c925
    HEAD_REF master # branch name
    #PATCHES example.patch #patch name
) 

vcpkg_configure_meson(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS 
)
vcpkg_install_meson()

vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)

# # Handle copyright
#file(INSTALL "${SOURCE_PATH}/COPYING" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright) No license in source?
file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/share/${PORT}/")
file(TOUCH "${CURRENT_PACKAGES_DIR}/share/${PORT}/copyright") #already installed by xproto
