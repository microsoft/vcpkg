set(VCPKG_POLICY_EMPTY_INCLUDE_FOLDER enabled)
if(NOT X_VCPKG_FORCE_VCPKG_X_LIBRARIES AND NOT VCPKG_TARGET_IS_WINDOWS)
    message(STATUS "Utils and libraries provided by '${PORT}' should be provided by your system! Install the required packages or force vcpkg libraries by setting X_VCPKG_FORCE_VCPKG_X_LIBRARIES in your triplet")
    set(VCPKG_POLICY_EMPTY_PACKAGE enabled)
    return()
endif()

find_program(XMLLINT_PATH NAMES xmllint PATHS "${CURRENT_HOST_INSTALLED_DIR}/tools/libxml2")
if(NOT XMLLINT_PATH)
    message(FATAL_ERROR "${PORT} requires xmllint which was not found!")
endif()

string(REGEX REPLACE "/[^/]+$" "" XMLLINT_DIR "${XMLLINT_PATH}")
file(TO_NATIVE_PATH "${XMLLINT_DIR}" XMLLINT_DIR_NATIVE)
message(STATUS "Using xmlling at: ${XMLLINT_PATH}")
vcpkg_add_to_path("${XMLLINT_DIR_NATIVE}")

vcpkg_find_acquire_program(PYTHON3)
get_filename_component(PYTHON3_DIR "${PYTHON3}" DIRECTORY)
file(TO_NATIVE_PATH "${PYTHON3_DIR}" PYTHON3_DIR_NATIVE)
vcpkg_add_to_path("${PYTHON3_DIR}")
set(ENV{PYTHON} "${PYTHON3}")

vcpkg_from_gitlab(
    GITLAB_URL https://gitlab.freedesktop.org/xorg
    OUT_SOURCE_PATH SOURCE_PATH
    REPO proto/xcbproto
    REF  "xcb-proto-${VERSION}"
    SHA512   69ac318e19c6a08d50624867b44f43c7cab7eb8e610635376b91b1b15c19a681bef246254565b920a26166726d501a2042fdc52c5ba37a509814cd5c766211e4
    HEAD_REF master
    PATCHES
        pkgconf.patch # vcpkg-make namespaces datarootdir below share/${PORT}
)

set(ENV{ACLOCAL} "aclocal -I \"${CURRENT_INSTALLED_DIR}/share/xorg/aclocal/\"")

set(XCBGEN_INSTALL_DIR "tools/${PORT}")
vcpkg_make_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    AUTORECONF
    OPTIONS
        ac_cv_path_PYTHON='${PYTHON3}'
        am_cv_python_pyexecdir=\\\${prefix}/${XCBGEN_INSTALL_DIR}
        am_cv_python_pythondir=\\\${prefix}/${XCBGEN_INSTALL_DIR}
)

vcpkg_make_install()
vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug")

vcpkg_install_copyright(
    FILE_LIST "${SOURCE_PATH}/COPYING"
    COMMENT "The installed protocol XML files also contain MIT and MIT-open-group license notices."
)
