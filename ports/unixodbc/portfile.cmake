vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO lurcher/unixODBC
    REF 6c8071b1bef4e4991e7b3023a1c1c712168a818e # v2.3.11
    SHA512 5c5b189e3b62935fdee5e25f5cf9b41fb2bc68fc9bd1652cab1b109032ab586978ba14d19e83328838b55e773f099046344bb4c84ec99edac309650ed863543e
    HEAD_REF master
)

vcpkg_make_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    AUTORECONF
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

foreach(FILE IN ITEMS config.h unixodbc_conf.h)
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/include/unixODBC/${FILE}" "#define BIN_PREFIX \"${CURRENT_INSTALLED_DIR}/tools/unixodbc/bin\"" "")
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/include/unixODBC/${FILE}" "#define DEFLIB_PATH \"${CURRENT_INSTALLED_DIR}/lib\"" "")
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/include/unixODBC/${FILE}" "#define EXEC_PREFIX \"${CURRENT_INSTALLED_DIR}\"" "")
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/include/unixODBC/${FILE}" "#define INCLUDE_PREFIX \"${CURRENT_INSTALLED_DIR}/include\"" "")
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/include/unixODBC/${FILE}" "#define LIB_PREFIX \"${CURRENT_INSTALLED_DIR}/lib\"" "")
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/include/unixODBC/${FILE}" "#define PREFIX \"${CURRENT_INSTALLED_DIR}\"" "")
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/include/unixODBC/${FILE}" "#define SYSTEM_FILE_PATH \"${CURRENT_INSTALLED_DIR}/etc\"" "")
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/include/unixODBC/${FILE}" "#define SYSTEM_LIB_PATH \"${CURRENT_INSTALLED_DIR}/lib\"" "")
endforeach()

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/unixodbcConfig.cmake" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")

vcpkg_install_copyright(
    COMMENT
        "All libraries are LGPL Version 2.1. All programs are GPL Version 2.0."
    FILE_LIST
        "${SOURCE_PATH}/LICENSE"
)
