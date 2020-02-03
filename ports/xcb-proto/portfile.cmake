## requires AUTOCONF, LIBTOOL and PKCONF
message(STATUS "----- ${PORT} requires autoconf, libtool, pkconf and xmllint from the system package manager! -----")

set(VCPKG_POLICY_EMPTY_INCLUDE_FOLDER enabled) 

find_program(XMLLINT_PATH NAMES xmllint PATHS "${CURRENT_INSTALLED_DIR}/tools/libxml2")
if(NOT XMLLINT_PATH)
    message(FATAL_ERROR "${PORT} requires xmllint which was not found!")
endif()

string(REGEX REPLACE "/[^/]+$" "" XMLLINT_DIR "${XMLLINT_PATH}")
file(TO_NATIVE_PATH "${XMLLINT_DIR}" XMLLINT_DIR_NATIVE)
message(STATUS "Using xmlling at: ${XMLLINT_PATH}")
vcpkg_add_to_path("${XMLLINT_DIR_NATIVE}")
#(also requires python2?)

vcpkg_find_acquire_program(PYTHON3)
get_filename_component(PYTHON3_DIR "${PYTHON3}" DIRECTORY)
file(TO_NATIVE_PATH "${PYTHON3_DIR}" PYTHON3_DIR_NATIVE)
vcpkg_add_to_path("${PYTHON3_DIR}")

vcpkg_from_gitlab(
    GITLAB_URL https://gitlab.freedesktop.org/xorg
    OUT_SOURCE_PATH SOURCE_PATH
    REPO proto/xcbproto
    REF  94228cde97d9aecfda04a8e699d462ba2b89e3a0 #v1.13
    SHA512 a6d44efb2fe7ff0b731e6024436cc6b07633839c69716e835c4aa8c02d67686068e966f811da61722ea5e2545cd621b76fb6a0f5775840387727acb61a9bdd44
    HEAD_REF master # branch name
    #PATCHES example.patch #patch name
) 

set(ENV{ACLOCAL} "aclocal -I ${CURRENT_INSTALLED_DIR}/share/xorg/aclocal/")

vcpkg_configure_make(
    SOURCE_PATH ${SOURCE_PATH}
    AUTOCONFIG
    #SKIP_CONFIGURE
    #NO_DEBUG
    #AUTO_HOST
    #AUTO_DST
    #PRERUN_SHELL ${SHELL_PATH}
    #OPTIONS
    #OPTIONS_DEBUG
    #OPTIONS_RELEASE
    PKG_CONFIG_PATHS_RELEASE "${CURRENT_INSTALLED_DIR}/lib/pkgconfig/"
    PKG_CONFIG_PATHS_DEBUG "${CURRENT_INSTALLED_DIR}/debug/lib/pkgconfig/"
)

vcpkg_install_make()

file(READ "${CURRENT_PACKAGES_DIR}/lib/pkgconfig/xcb-proto.pc" _contents)
string(REPLACE "libdir=${CURRENT_PACKAGES_DIR}/lib" "libdir=\${prefix}/lib" _contents "${_contents}")
file(WRITE "${CURRENT_PACKAGES_DIR}/lib/pkgconfig/xcb-proto.pc" "${_contents}")

file(READ "${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig/xcb-proto.pc" _contents)
string(REPLACE "libdir=${CURRENT_PACKAGES_DIR}/debug/lib" "libdir=\${prefix}/lib" _contents "${_contents}")
string(REPLACE "datarootdir=\${prefix}/share" "datarootdir=\${prefix}/../share" _contents "${_contents}")
file(WRITE "${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig/xcb-proto.pc" "${_contents}")

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

# # Handle copyright
file(INSTALL "${SOURCE_PATH}/COPYING" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)

