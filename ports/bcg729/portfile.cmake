vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO BelledonneCommunications/bcg729
    REF "${VERSION}"
    SHA512 54befb0795176cbb7a37aa222491634b67e79268beaecc4713a3020d64773682ff78ec9c5d8c223c05ef939a38b64c85df9a79708f5f2647643ce4329abc29a8
    HEAD_REF master
    PATCHES
        disable-alt-packaging.patch
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
)

if (VCPKG_TARGET_IS_WINDOWS AND VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    vcpkg_replace_string("${SOURCE_PATH}/include/bcg729/decoder.h" "#ifdef BCG729_STATIC" "#if 1")
    vcpkg_replace_string("${SOURCE_PATH}/include/bcg729/encoder.h" "#ifdef BCG729_STATIC" "#if 1")
endif()

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(PACKAGE_NAME BCG729 CONFIG_PATH share/BCG729/cmake)
vcpkg_fixup_pkgconfig()
vcpkg_copy_pdbs()

file(REMOVE_RECURSE
    "${CURRENT_PACKAGES_DIR}/debug/include"
    "${CURRENT_PACKAGES_DIR}/debug/share"
)

vcpkg_install_copyright(
    FILE_LIST "${SOURCE_PATH}/LICENSE.txt"
    COMMENT [[
bcg729 is dual licensed, and is available either:
 - under a GNU/GPLv3 license, for free (open source). See below.
 - under a proprietary license, for a fee, to be used in closed source applications.
   Contact Belledonne Communications (https://www.linphone.org/contact)
   for any question about costs and services.]]
)
