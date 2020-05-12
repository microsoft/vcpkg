include(vcpkg_common_functions)

vcpkg_download_distfile(ARCHIVE
    URLS "https://www.freetds.org/files/stable/freetds-1.1.17.tar.bz2"
    FILENAME "freetds-1.1.17.tar.bz2"
    SHA512 3746ea009403960950fd619ffaf6433cfc92c34a8261b15e61009f01a1446e5a5a59413cd48e5511bbf3a0224f54b40daa713187bd20ca43105c5f8c68f4b88e
)

vcpkg_extract_source_archive_ex(
    OUT_SOURCE_PATH SOURCE_PATH
    ARCHIVE ${ARCHIVE}
    PATCHES
        crypt32.patch
)

set(BUILD_freetds_openssl OFF)
if("openssl" IN_LIST FEATURES)
    set(BUILD_freetds_openssl ON)
endif()

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DWITH_OPENSSL=${BUILD_freetds_openssl}
)

vcpkg_install_cmake()
vcpkg_copy_pdbs()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(REMOVE ${CURRENT_PACKAGES_DIR}/bin/bsqldb.exe)
file(REMOVE ${CURRENT_PACKAGES_DIR}/bin/bsqlodbc.exe)
file(REMOVE ${CURRENT_PACKAGES_DIR}/bin/datacopy.exe)
file(REMOVE ${CURRENT_PACKAGES_DIR}/bin/defncopy.exe)
file(REMOVE ${CURRENT_PACKAGES_DIR}/bin/freebcp.exe)
file(REMOVE ${CURRENT_PACKAGES_DIR}/bin/tdspool.exe)
file(REMOVE ${CURRENT_PACKAGES_DIR}/bin/tsql.exe)
file(REMOVE ${CURRENT_PACKAGES_DIR}/bin/bsqldb)
file(REMOVE ${CURRENT_PACKAGES_DIR}/bin/bsqlodbc)
file(REMOVE ${CURRENT_PACKAGES_DIR}/bin/datacopy)
file(REMOVE ${CURRENT_PACKAGES_DIR}/bin/defncopy)
file(REMOVE ${CURRENT_PACKAGES_DIR}/bin/freebcp)
file(REMOVE ${CURRENT_PACKAGES_DIR}/bin/tdspool)
file(REMOVE ${CURRENT_PACKAGES_DIR}/bin/tsql)
file(REMOVE ${CURRENT_PACKAGES_DIR}/debug/bin/bsqldb.exe)
file(REMOVE ${CURRENT_PACKAGES_DIR}/debug/bin/bsqlodbc.exe)
file(REMOVE ${CURRENT_PACKAGES_DIR}/debug/bin/datacopy.exe)
file(REMOVE ${CURRENT_PACKAGES_DIR}/debug/bin/defncopy.exe)
file(REMOVE ${CURRENT_PACKAGES_DIR}/debug/bin/freebcp.exe)
file(REMOVE ${CURRENT_PACKAGES_DIR}/debug/bin/tdspool.exe)
file(REMOVE ${CURRENT_PACKAGES_DIR}/debug/bin/tsql.exe)
file(REMOVE ${CURRENT_PACKAGES_DIR}/debug/bin/bsqldb)
file(REMOVE ${CURRENT_PACKAGES_DIR}/debug/bin/bsqlodbc)
file(REMOVE ${CURRENT_PACKAGES_DIR}/debug/bin/datacopy)
file(REMOVE ${CURRENT_PACKAGES_DIR}/debug/bin/defncopy)
file(REMOVE ${CURRENT_PACKAGES_DIR}/debug/bin/freebcp)
file(REMOVE ${CURRENT_PACKAGES_DIR}/debug/bin/tdspool)
file(REMOVE ${CURRENT_PACKAGES_DIR}/debug/bin/tsql)

if(VCPKG_LIBRARY_LINKAGE STREQUAL static)
    file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/bin ${CURRENT_PACKAGES_DIR}/debug/bin)
endif()

file(INSTALL ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
