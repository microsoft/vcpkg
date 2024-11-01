vcpkg_download_distfile(ARCHIVE
    URLS "https://ftp.postgresql.org/pub/source/v${VERSION}/postgresql-${VERSION}.tar.bz2"
         "https://www.mirrorservice.org/sites/ftp.postgresql.org/source/v${VERSION}/postgresql-${VERSION}.tar.bz2"
    FILENAME "postgresql-${VERSION}.tar.bz2"
    SHA512 ae6741298abe986c9f09a6eee9fa2df26c3bbdffcbd0ff3f33332456e09f95195e4535f00a9437f2877e03e2e43a78be9a355303e7cf43bcb688b657ca7289f3
)

vcpkg_extract_source_archive(
    SOURCE_PATH
    ARCHIVE "${ARCHIVE}"
    PATCHES
        windows/macro-def.patch
        windows/spin_delay.patch
)

set(required_programs BISON FLEX PERL PYTHON3)
foreach(program_name IN LISTS required_programs)
    vcpkg_find_acquire_program(${program_name})
endforeach()

if("nls" IN_LIST FEATURES)
    list(APPEND OPTIONS -Dnls=enabled)
    vcpkg_add_to_path(PREPEND "${CURRENT_HOST_INSTALLED_DIR}/tools/gettext/bin")
else()
    list(APPEND OPTIONS -Dnls=disabled)
endif()

if("icu" IN_LIST FEATURES)
    list(APPEND OPTIONS -Dicu=enabled)
else()
    list(APPEND OPTIONS -Dicu=disabled)
endif()

if("lz4" IN_LIST FEATURES)
    list(APPEND OPTIONS -Dlz4=enabled)
else()
    list(APPEND OPTIONS -Dlz4=disabled)
endif()

if("openssl" IN_LIST FEATURES)
    list(APPEND OPTIONS -Dssl=openssl)
else()
    list(APPEND OPTIONS -Dssl=none)
endif()

if("python" IN_LIST FEATURES)
    list(APPEND OPTIONS -Dplpython=enabled)
else()
    list(APPEND OPTIONS -Dplpython=disabled)
endif()

if("tcl" IN_LIST FEATURES)
    list(APPEND OPTIONS -Dpltcl=enabled)
else()
    list(APPEND OPTIONS -Dpltcl=disabled)
endif()

if("xml" IN_LIST FEATURES)
    list(APPEND OPTIONS -Dlibxml=enabled)
else()
    list(APPEND OPTIONS -Dlibxml=disabled)
endif()

if("xslt" IN_LIST FEATURES)
    list(APPEND OPTIONS -Dlibxslt=enabled)
else()
    list(APPEND OPTIONS -Dlibxslt=disabled)
endif()

if("zlib" IN_LIST FEATURES)
    list(APPEND OPTIONS -Dzlib=enabled)
else()
    list(APPEND OPTIONS -Dzlib=disabled)
endif()

if("zstd" IN_LIST FEATURES)
    list(APPEND OPTIONS -Dzstd=enabled)
else()
    list(APPEND OPTIONS -Dzstd=disabled)
endif()

vcpkg_configure_meson(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
       -Ddocs=disabled
       ${OPTIONS}
    ADDITIONAL_BINARIES
        flex='${FLEX}'
        bison='${BISON}'
        perl='${PERL}'
        python='${PYTHON3}'
)

vcpkg_install_meson()

set(tools clusterdb createdb createuser dropdb dropuser ecpg initdb oid2name pgbench pg_amcheck pg_archivecleanup pg_basebackup pg_checksums pg_combinebackup pg_config pg_controldata pg_createsubscriber pg_ctl pg_dump pg_dumpall pg_isready pg_receivewal pg_recvlogical pg_resetwal pg_restore pg_rewind pg_test_fsync pg_test_timing pg_upgrade pg_verifybackup pg_waldump pg_walsummary postgres psql reindexdb vacuumdb vacuumlo)

vcpkg_copy_tools(TOOL_NAMES ${tools} AUTO_CLEAN)

vcpkg_fixup_pkgconfig()
configure_file("${CMAKE_CURRENT_LIST_DIR}/vcpkg-cmake-wrapper.cmake" "${CURRENT_PACKAGES_DIR}/share/postgresql/vcpkg-cmake-wrapper.cmake" @ONLY)

if(VCPKG_TARGET_IS_WINDOWS AND NOT VCPKG_TARGET_IS_MINGW)
    file(GLOB LIBAS "${CURRENT_PACKAGES_DIR}/lib/*.a")
    if(NOT DEFINED VCPKG_BUILD_TYPE)
        file(GLOB DEBUG_LIBAS "${CURRENT_PACKAGES_DIR}/debug/lib/*.a")
    endif()
    if(LIBAS OR DEBUG_LIBAS)
        file(REMOVE ${LIBAS} ${DEBUG_LIBAS})
    endif()
endif()

file(REMOVE_RECURSE
    "${CURRENT_PACKAGES_DIR}/lib/postgresql"
    "${CURRENT_PACKAGES_DIR}/debug/lib/postgresql"
    "${CURRENT_PACKAGES_DIR}/debug/share"
)

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/bin" "${CURRENT_PACKAGES_DIR}/debug/bin")
endif()

file(INSTALL "${CURRENT_PORT_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/COPYRIGHT")
