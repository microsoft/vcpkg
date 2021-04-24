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
    set(ZLIB_LIBS_DEBUG "-L${CURRENT_INSTALLED_DIR}/debug/lib -lzlibd")
    set(ZLIB_LIBS_RELEASE "-L${CURRENT_INSTALLED_DIR}/lib -lzlib")
    set(GLIB_LIBS_DEBUG "-L${CURRENT_INSTALLED_DIR}/debug/lib ${GLIBS} -lzlibd")
    set(GLIB_LIBS_RELEASE "-L${CURRENT_INSTALLED_DIR}/lib ${GLIBS} -lzlib")
else()
    set(ZLIB_LIBS_DEBUG "-L${CURRENT_INSTALLED_DIR}/debug/lib -lz")
    set(ZLIB_LIBS_RELEASE "-L${CURRENT_INSTALLED_DIR}/lib -lz")
    set(GLIB_LIBS_DEBUG "-L${CURRENT_INSTALLED_DIR}/debug/lib ${GLIBS} -lz -pthread")
    set(GLIB_LIBS_RELEASE "-L${CURRENT_INSTALLED_DIR}/lib ${GLIBS} -lz -pthread")
endif()

set(ENV{GLIB_CFLAGS} "-I${CURRENT_INSTALLED_DIR}/include")
set(ENV{ZLIB_CFLAGS} "-I${CURRENT_INSTALLED_DIR}/include")
# set(VCPKG_BUILD_TYPE release) # We theoretically only need the release version. Lets build debug just for testing
vcpkg_configure_make(
    SOURCE_PATH ${SOURCE_PATH}
    AUTOCONFIG
    CONFIG_DEPENDENT_ENVIRONMENT GLIB_LIBS ZLIB_LIBS
)
vcpkg_install_make()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/tools/${PORT}/debug) # no need for debug tools

vcpkg_copy_tool_dependencies(${CURRENT_PACKAGES_DIR}/tools/${PORT}/bin)

# # Handle copyright
file(INSTALL "${SOURCE_PATH}/COPYING" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
