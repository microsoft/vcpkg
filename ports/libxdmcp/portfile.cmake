#SET(VCPKG_POLICY_DLLS_WITHOUT_LIBS enabled) # this is a lie but the lib has a different name than the dll
if(NOT X_VCPKG_FORCE_VCPKG_X_LIBRARIES AND NOT VCPKG_TARGET_IS_WINDOWS)
    message(STATUS "Utils and libraries provided by '${PORT}' should be provided by your system! Install the required packages or force vcpkg libraries by setting X_VCPKG_FORCE_VCPKG_X_LIBRARIES in your triplet")
    set(VCPKG_POLICY_EMPTY_PACKAGE enabled)
else()
vcpkg_from_gitlab(
    GITLAB_URL "https://gitlab.freedesktop.org/xorg"
    OUT_SOURCE_PATH SOURCE_PATH
    REPO "lib/libxdmcp"
    REF  libXdmcp-${VERSION}
    SHA512 e56baff7e7556954e10d1702b469c42fccae218692a9379306b08b513a7453d504dcbd39d03acdfe23f8f9f3f7b0fec5ae517ce17f3aa0fd5f1947d04cb73663
    HEAD_REF master
    PATCHES configure.ac.patch
)

set(ENV{ACLOCAL} "aclocal -I \"${CURRENT_INSTALLED_DIR}/share/xorg/aclocal/\"")
if(VCPKG_TARGET_IS_WINDOWS)
    set(OPTIONS --disable-dependency-tracking)
    string(APPEND VCPKG_C_FLAGS "/showIncludes ")
    string(APPEND VCPKG_CXX_FLAGS "/showIncludes ")
endif()
vcpkg_configure_make(
    SOURCE_PATH ${SOURCE_PATH}
    AUTOCONFIG
    OPTIONS ${OPTIONS} --enable-unit-tests=no
)

vcpkg_install_make()
vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

# Handle copyright
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/COPYING")
endif()
