set(VCPKG_POLICY_EMPTY_INCLUDE_FOLDER enabled) # Tool build no library or includes

vcpkg_from_gitlab(
    GITLAB_URL https://gitlab.freedesktop.org/
    OUT_SOURCE_PATH SOURCE_PATH
    REPO pkg-config/pkg-config
    REF  edf8e6f0ea77ede073f07bff0d2ae1fc7a38103b #v0.29.2
    SHA512 537bace09ff183ec793587fc7cf091d75cd5ec34efc1261227de70a15631f40558528f19dbe9e3f2eb8bc24bed21003a01c7766c849ae498031c0c1ae322e314
    HEAD_REF master
) 

# Remove if GLIB installs a *.pc file or keep it to make it independent of pkg-config itself
set(GLIBS "-lglib-2.0 -lgio-2.0 -lgmodule-2.0 -lgobject-2.0 -lgthread-2.0")
if(VCPKG_TARGET_IS_WINDOWS)
    set(GLIB_LIBS_DEBUG "-L${CURRENT_INSTALLED_DIR}/debug/lib ${GLIBS} -lzlibd")
    set(GLIB_LIBS_RELEASE "-L${CURRENT_INSTALLED_DIR}/lib ${GLIBS} -lzlib")
else()
    set(GLIB_LIBS_DEBUG "-L${CURRENT_INSTALLED_DIR}/lib ${GLIBS} -lz")
    set(GLIB_LIBS_RELEASE "-L${CURRENT_INSTALLED_DIR}/lib ${GLIBS} -lz")
endif()

set(ENV{GLIB_CFLAGS} "-I${CURRENT_INSTALLED_DIR}/include")
vcpkg_configure_make(
    SOURCE_PATH ${SOURCE_PATH}
    AUTOCONFIG
    CONFIG_DEPENDENT_ENVIROMNENT "GLIB_LIBS"
)

vcpkg_install_make()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/tools/${PORT}/debug) # no need for debug tools

vcpkg_copy_tool_dependencies(${CURRENT_PACKAGES_DIR}/tools/${PORT}/bin)

# # Handle copyright
file(INSTALL "${SOURCE_PATH}/COPYING" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)

# pkg-config depends on glib.  Note that glib build-depends on pkg-config,
# but you can just set the corresponding environment variables (ZLIB_LIBS,
# ZLIB_CFLAGS are the only needed ones when this is written) to build it.

# pkg-config also either needs an earlier version of itself to find glib
# or you need to set GLIB_CFLAGS and GLIB_LIBS to the correct values for
# where it's installed in your system.

# If this requirement is too cumbersome, a bundled copy of a recent glib
# stable release is included. Pass --with-internal-glib to configure to
# use this copy.