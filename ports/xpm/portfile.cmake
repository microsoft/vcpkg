vcpkg_from_gitlab(
    GITLAB_URL https://gitlab.freedesktop.org/xorg
    OUT_SOURCE_PATH SOURCE_PATH
    REPO lib/libxpm
    REF b0fc485495a694816d76a43978e2cfd5575c554d # 3.5.13
    SHA512  4637d7b4c1a0aa0a8f3e01eca53dffe61875fc2c1e1c9061d3cafd677cedb4b9e0f095dbb071de16f970c027cba2032d9dddb386032ae0321fa9562a42a9957e
    HEAD_REF master # branch name
    #PATCHES example.patch #patch name
) 

set(ENV{ACLOCAL} "aclocal -I \"${CURRENT_INSTALLED_DIR}/share/xorg/aclocal/\"")

vcpkg_configure_make(
    SOURCE_PATH "${SOURCE_PATH}"
    AUTOCONFIG
    #SKIP_CONFIGURE
    #NO_DEBUG
    #AUTO_HOST
    #AUTO_DST
    #PRERUN_SHELL "export ACLOCAL=\"aclocal -I ${CURRENT_INSTALLED_DIR}/share/xorg-macros/aclocal/\""
    #OPTIONS
    #OPTIONS_DEBUG
    #OPTIONS_RELEASE
)

vcpkg_install_make()
vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

# # Handle copyright
file(INSTALL "${SOURCE_PATH}/COPYING" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)

file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/tools/${PORT}")
file(RENAME "${CURRENT_PACKAGES_DIR}/bin/cxpm${VCPKG_TARGET_EXECUTABLE_SUFFIX}" "${CURRENT_PACKAGES_DIR}/tools/${PORT}/cxpm${VCPKG_TARGET_EXECUTABLE_SUFFIX}")
file(RENAME "${CURRENT_PACKAGES_DIR}/bin/sxpm${VCPKG_TARGET_EXECUTABLE_SUFFIX}" "${CURRENT_PACKAGES_DIR}/tools/${PORT}/sxpm${VCPKG_TARGET_EXECUTABLE_SUFFIX}")
file(MAKE_DIRECTORY  "${CURRENT_PACKAGES_DIR}/share/${PORT}")
file(RENAME "${CURRENT_PACKAGES_DIR}/share/man" "${CURRENT_PACKAGES_DIR}/share/${PORT}/man")
if(VCPKG_LIBRARY_LINKAGE STREQUAL static OR NOT VCPKG_TARGET_IS_WINDOWS)
        file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/bin" "${CURRENT_PACKAGES_DIR}/debug/bin")
endif()