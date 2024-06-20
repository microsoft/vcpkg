vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO OpenPrinting/cups
    REF "v${VERSION}"
    SHA512 9def5d66ff000fa36cc00749c9e3533348f55fa34724bab9fe8d982db990003c499b4acf2c8ae81d30a0c0ffded39b51f36eb391ab06a1da79bbe7d28a270cc8
    HEAD_REF master
)

file(REMOVE "${SOURCE_PATH}/configure.ac")
vcpkg_configure_make(
    SOURCE_PATH "${SOURCE_PATH}"
    COPY_SOURCE
)

#vcpkg_build_make(BUILD_TARGET depend LOGFILE_ROOT depend)
vcpkg_install_make()
vcpkg_fixup_pkgconfig()
vcpkg_copy_pdbs()

#TODO: Check some full install path defines from the configure log an how they are used in the code. 

set(cups-config-file "${CURRENT_PACKAGES_DIR}/tools/cups/bin/cups-config")
file(READ "${cups-config-file}" cups-config)
string(REPLACE 
[[#!/bin/sh]]
[[#!/bin/sh
vcpkg_prefix=$( realpath "$0"  ) && dirname "$vcpkg_prefix"]] 
cups-config "${cups-config}")
string(REPLACE "${CURRENT_INSTALLED_DIR}" [[${vcpkg_prefix}/../../..]] cups-config "${cups-config}")
file(WRITE "${cups-config-file}" "${cups-config}")

vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/etc/cups/cupsd.conf" "${CURRENT_INSTALLED_DIR}" "")
vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/etc/cups/cups-files.conf" "${CURRENT_INSTALLED_DIR}" "")

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

file(REMOVE_RECURSE 
  "${CURRENT_PACKAGES_DIR}/etc/cups/ppd"
  "${CURRENT_PACKAGES_DIR}/etc/cups/ssl"
  "${CURRENT_PACKAGES_DIR}/lib/cups/driver"
  "${CURRENT_PACKAGES_DIR}/share/cups/cups/data"
  "${CURRENT_PACKAGES_DIR}/share/cups/cups/model"
  "${CURRENT_PACKAGES_DIR}/share/cups/cups/banners"
  "${CURRENT_PACKAGES_DIR}/share/cups/cups/profiles"
  "${CURRENT_PACKAGES_DIR}/var"
)

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")

set(VCPKG_POLICY_SKIP_ABSOLUTE_PATHS_CHECK enabled)
set(VCPKG_POLICY_ALLOW_EMPTY_FOLDERS enabled)
