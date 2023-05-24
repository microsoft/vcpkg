set(VCPKG_POLICY_EMPTY_INCLUDE_FOLDER enabled) 
if(NOT X_VCPKG_FORCE_VCPKG_X_LIBRARIES AND NOT VCPKG_TARGET_IS_WINDOWS)
    message(STATUS "Utils and libraries provided by '${PORT}' should be provided by your system! Install the required packages or force vcpkg libraries by setting X_VCPKG_FORCE_VCPKG_X_LIBRARIES in your triplet")
    set(VCPKG_POLICY_EMPTY_PACKAGE enabled)
else()

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
    REF  70ca65fa35c3760661b090bc4b2601daa7a099b8 #v1.14.1 + patches
    SHA512   9e08e1d2ab1fe7a8d3985568918a858ddfb31b8016ccac8ea2447631e7cede3bcc7b1ed86491d497ab871674c9b55d94fab25ee13ff6de9a44590b91d9166fda
    HEAD_REF master
) 

set(ENV{ACLOCAL} "aclocal -I \"${CURRENT_INSTALLED_DIR}/share/xorg/aclocal/\"")

vcpkg_configure_make(
    SOURCE_PATH "${SOURCE_PATH}"
    AUTOCONFIG
    OPTIONS
        ac_cv_path_PYTHON='${PYTHON3}'
        am_cv_python_pyexecdir=\\\${prefix}/tools/python3/site-packages
        am_cv_python_pythondir=\\\${prefix}/tools/python3/site-packages
        )

vcpkg_install_make()
vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

file(INSTALL "${SOURCE_PATH}/COPYING" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
endif()
