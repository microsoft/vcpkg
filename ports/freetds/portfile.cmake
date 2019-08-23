# Common Ambient Variables:
#   VCPKG_ROOT_DIR = <C:\path\to\current\vcpkg>
#   TARGET_TRIPLET is the current triplet (x86-windows, etc)
#   PORT is the current port name (zlib, etc)
#   CURRENT_BUILDTREES_DIR = ${VCPKG_ROOT_DIR}\buildtrees\${PORT}
#   CURRENT_PACKAGES_DIR  = ${VCPKG_ROOT_DIR}\packages\${PORT}_${TARGET_TRIPLET}
#

include(vcpkg_common_functions)
set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/freetds-1.1.6)
vcpkg_download_distfile(ARCHIVE
    URLS "https://www.freetds.org/files/stable/freetds-1.1.6.tar.bz2"
    FILENAME "freetds-1.1.6.tar.bz2"
    SHA512 160c8638302fd36a3f42d031dbd58525cde899b64d320f6187ce5865ea2c049a1af63be419623e4cd18ccf229dd2ee7ec509bc5721c3371de0f31710dad7470d
)
vcpkg_extract_source_archive(${ARCHIVE})

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

# Handle copyright
file(COPY ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/freetds)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/freetds/COPYING ${CURRENT_PACKAGES_DIR}/share/freetds/copyright)
