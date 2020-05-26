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
    REF  73d84bf39be7f3d8c90d7494bd4641456f2c8ef9 #v1.14
    SHA512  e3ee11fa487102b6218dc4b7de361d6212b2dc9287bd0aba1c27310fb378701a9baddd8f7c879679ec13f5143f88ad532f8e485c67602cfa021386f4d3a5bb6d
    HEAD_REF master # branch name
    #PATCHES example.patch #patch name
) 

set(ENV{ACLOCAL} "aclocal -I \"${CURRENT_INSTALLED_DIR}/share/xorg/aclocal/\"")

vcpkg_configure_make(
    SOURCE_PATH ${SOURCE_PATH}
    AUTOCONFIG
)

vcpkg_install_make()
vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

# # Handle copyright
file(INSTALL "${SOURCE_PATH}/COPYING" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)

