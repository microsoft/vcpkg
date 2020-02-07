message(STATUS "----- ${PORT} requires autoconf, libtool and pkconf from the system package manager! -----")

vcpkg_from_gitlab(
    GITLAB_URL https://gitlab.freedesktop.org/
    OUT_SOURCE_PATH SOURCE_PATH
    REPO dbus/dbus
    REF 99f0821bfbff1f23d19b8f316f2c559744b28e51 #1.13.10
    SHA512  abbe1290eb93a23f113a8e878d077a5b2d1b4b89750e53b71ce389cee9931155d6bb858d3757f74505b6f6b3f2cea6654c3bb2dd0ebe3415277d05eaa296d4a8
    HEAD_REF master # branch name
    #PATCHES example.patch #patch name
) 

vcpkg_configure_make(
    SOURCE_PATH ${SOURCE_PATH}
    AUTOCONFIG
    #SKIP_CONFIGURE
    #NO_DEBUG
    #AUTO_HOST
    #AUTO_DST
    #PRERUN_SHELL "export ACLOCAL=\"aclocal -I ${CURRENT_INSTALLED_DIR}/share/xorg-macros/aclocal/\""
    OPTIONS ${OPTIONS} --enable-tests=no
    #OPTIONS_DEBUG
    #OPTIONS_RELEASE
    PKG_CONFIG_PATHS_RELEASE "${CURRENT_INSTALLED_DIR}/lib/pkgconfig"
    PKG_CONFIG_PATHS_DEBUG "${CURRENT_INSTALLED_DIR}/debug/lib/pkgconfig"
)

vcpkg_install_make()
vcpkg_fixup_cmake_targets(CONFIG_PATH "lib/cmake/DBus1")
vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)

# # Handle copyright
file(INSTALL "${SOURCE_PATH}/COPYING" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)

file(REMOVE_RECURSE     "${CURRENT_PACKAGES_DIR}/debug/var/"
                        "${CURRENT_PACKAGES_DIR}/var"
                        "${CURRENT_PACKAGES_DIR}/share/dbus-1/services"
                        "${CURRENT_PACKAGES_DIR}/share/dbus-1/session.d"
                        "${CURRENT_PACKAGES_DIR}/share/dbus-1/system-services"
                        "${CURRENT_PACKAGES_DIR}/share/dbus-1/system.d")

file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/tools/${PORT}")
set(TOOLS cleanup-sockets daemon launch monitor run-session send test-tool update-activation-environment uuidgen)
foreach(_tool ${TOOLS})
    file(RENAME "${CURRENT_PACKAGES_DIR}/bin/dbus-${_tool}${VCPKG_TARGET_EXECUTABLE_SUFFIX}" "${CURRENT_PACKAGES_DIR}/tools/${PORT}/dbus-${_tool}${VCPKG_TARGET_EXECUTABLE_SUFFIX}")
endforeach()

 if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
        file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/bin" "${CURRENT_PACKAGES_DIR}/debug/bin")
endif()