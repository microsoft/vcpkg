vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO lurcher/unixODBC
    REF v${VERSION}
    SHA512 c70c1eff4bf2f34a968bd8007dc02260d1f583d6295deccde9a2c22b2592e6daed4ee3ef40b0b3445c09444a7d08d128a854b56502675fa3e6d2f908a9b1bcdb
    HEAD_REF master
    PATCHES
        subdirs.diff
)

vcpkg_libltdl_get_vars(LIBLTDL)
set(ENV{LIBTOOLIZE} "${LIBLTDL_LIBTOOLIZE}")

vcpkg_make_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    AUTORECONF
    OPTIONS_RELEASE
        ${LIBLTDL_OPTIONS_RELEASE}
    OPTIONS_DEBUG
        ${LIBLTDL_OPTIONS_DEBUG}
)
vcpkg_make_install()
vcpkg_copy_pdbs()
vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE
    "${CURRENT_PACKAGES_DIR}/debug/etc"
    "${CURRENT_PACKAGES_DIR}/debug/include"
    "${CURRENT_PACKAGES_DIR}/debug/share"
    "${CURRENT_PACKAGES_DIR}/etc"
    "${CURRENT_PACKAGES_DIR}/share/${PORT}/man1"
    "${CURRENT_PACKAGES_DIR}/share/${PORT}/man5"
    "${CURRENT_PACKAGES_DIR}/share/${PORT}/man7"
)

vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/include/unixODBC/unixodbc_conf.h" "#define BIN_PREFIX \"${CURRENT_INSTALLED_DIR}/tools/unixodbc/bin\"" "/* redacted */")
vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/include/unixODBC/unixodbc_conf.h" "#define DEFLIB_PATH \"${CURRENT_INSTALLED_DIR}/lib\"" "/* redacted */")
vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/include/unixODBC/unixodbc_conf.h" "#define EXEC_PREFIX \"${CURRENT_INSTALLED_DIR}\"" "/* redacted */")
vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/include/unixODBC/unixodbc_conf.h" "#define INCLUDE_PREFIX \"${CURRENT_INSTALLED_DIR}/include\"" "/* redacted */")
vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/include/unixODBC/unixodbc_conf.h" "#define LIB_PREFIX \"${CURRENT_INSTALLED_DIR}/lib\"" "/* redacted */")
vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/include/unixODBC/unixodbc_conf.h" "#define PREFIX \"${CURRENT_INSTALLED_DIR}\"" "/* redacted */")
vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/include/unixODBC/unixodbc_conf.h" "#define SYSTEM_FILE_PATH \"${CURRENT_INSTALLED_DIR}/etc\"" "/* redacted */")
vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/include/unixODBC/unixodbc_conf.h" "#define SYSTEM_LIB_PATH \"${CURRENT_INSTALLED_DIR}/lib\"" "/* redacted */")

configure_file("${CMAKE_CURRENT_LIST_DIR}/unofficial-unixodbc-config.cmake" "${CURRENT_PACKAGES_DIR}/share/unofficial-unixodbc/unofficial-unixodbc-config.cmake" @ONLY)
file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/unixodbcConfig.cmake" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}") # legacy
file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")

vcpkg_install_copyright(
    COMMENT
        "All libraries are LGPL Version 2.1. All programs are GPL Version 2.0."
    FILE_LIST
        "${SOURCE_PATH}/COPYING"
        "${SOURCE_PATH}/exe/COPYING"
)
