vcpkg_from_github(
	OUT_SOURCE_PATH SOURCE_PATH
	REPO marlam/gta
	REF "libgta-${VERSION}"
	SHA512 e64a1e2a64538ae16a5ac1f1bdf43932e14d9db95a88e358d9ce6182b03ec423b5205888e0a0ac15f9ab07957c67245151ebe8e2e13800047fc48a44c2f5fde7
	HEAD_REF master
    # This correction is included in the official 1.2.1 release archive:
    # https://marlam.de/gta/releases/libgta-1.2.1.tar.xz
    PATCHES
        version.patch
)
string(APPEND SOURCE_PATH "/libgta")


string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "dynamic" ENABLE_SHARED_LIBS)
string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "static"  ENABLE_STATIC_LIBS)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DGTA_BUILD_SHARED_LIB=${ENABLE_SHARED_LIBS}
        -DGTA_BUILD_STATIC_LIB=${ENABLE_STATIC_LIBS}
        -DGTA_BUILD_DOCUMENTATION=OFF
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH "lib/cmake/GTA-${VERSION}" PACKAGE_NAME "GTA")
vcpkg_copy_pdbs()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    vcpkg_replace_string(
        "${CURRENT_PACKAGES_DIR}/include/gta/gta.h"
        "#define GTA_H"
        "#define GTA_H\n#define GTA_STATIC"
    )
endif()

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/COPYING")

vcpkg_fixup_pkgconfig()
