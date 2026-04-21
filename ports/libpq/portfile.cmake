vcpkg_download_distfile(ARCHIVE
    URLS "https://ftp.postgresql.org/pub/source/v${VERSION}/postgresql-${VERSION}.tar.bz2"
         "https://www.mirrorservice.org/sites/ftp.postgresql.org/source/v${VERSION}/postgresql-${VERSION}.tar.bz2"
    FILENAME "postgresql-${VERSION}.tar.bz2"
    SHA512 fdbe6d726f46738cf14acab96e5c05f7d65aefe78563281b416bb14a27c7c42e4df921e26b32816a5030ddbe506b95767e2c74a35afc589916504df38d1cb11c
)

vcpkg_extract_source_archive(
    SOURCE_PATH
    ARCHIVE "${ARCHIVE}"
    PATCHES
        meson-vcpkg.patch
        windows/macro-def.patch
        windows/spin_delay.patch
        windows/getopt.patch
)

file(GLOB _py3_include_path "${CURRENT_HOST_INSTALLED_DIR}/include/python3*")
string(REGEX MATCH "python3\\.([0-9]+)" _python_version_tmp "${_py3_include_path}")
set(PYTHON_VERSION_MINOR "${CMAKE_MATCH_1}")

vcpkg_cmake_get_vars(cmake_vars_file)
include("${cmake_vars_file}")

vcpkg_find_acquire_program(BISON)
vcpkg_find_acquire_program(FLEX)
vcpkg_find_acquire_program(PERL)

vcpkg_list(SET MESON_OPTIONS_RELEASE)
vcpkg_list(SET MESON_OPTIONS)
foreach(option IN ITEMS icu lz4 zlib zstd)
    if(option IN_LIST FEATURES)
        list(APPEND MESON_OPTIONS -D${option}=enabled)
    endif()
endforeach()

if("openssl" IN_LIST FEATURES)
    list(APPEND MESON_OPTIONS -Dssl=openssl)
else()
    list(APPEND MESON_OPTIONS -Dssl=none)
endif()

if("nls" IN_LIST FEATURES)
    list(APPEND MESON_OPTIONS -Dnls=enabled)
endif()

if("client" IN_LIST FEATURES)
    list(APPEND MESON_OPTIONS_RELEASE -Dtools=enabled)
endif()

vcpkg_configure_meson(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -Dauto_features=disabled
        ${MESON_OPTIONS}
        # cannot use ADDITIONAL_BINARIES for "native" programs
        "-DBISON=['${BISON}']"
        "-DFLEX=['${FLEX}']"
        "-DPERL=${PERL}"
    OPTIONS_RELEASE
        ${MESON_OPTIONS_RELEASE}
)
vcpkg_install_meson()
vcpkg_fixup_pkgconfig()

vcpkg_copy_tools(TOOL_NAMES ecpg AUTO_CLEAN)
if("client" IN_LIST FEATURES)
    vcpkg_copy_tools(
        TOOL_NAMES
            clusterdb createdb createuser
            dropdb dropuser
            pg_amcheck
            pg_basebackup pgbench
            pg_combinebackup pg_config pg_createsubscriber
            pg_dump pg_dumpall
            pg_isready
            pg_receivewal pg_recvlogical pg_restore
            pg_verifybackup
            psql
            reindexdb
            vacuumdb
        AUTO_CLEAN
    )
endif()


file(REMOVE_RECURSE
    "${CURRENT_PACKAGES_DIR}/debug/include"
    "${CURRENT_PACKAGES_DIR}/debug/share"
)

configure_file("${CMAKE_CURRENT_LIST_DIR}/vcpkg-cmake-wrapper.cmake" "${CURRENT_PACKAGES_DIR}/share/postgresql/vcpkg-cmake-wrapper.cmake" @ONLY)
file(INSTALL "${CURRENT_PORT_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/COPYRIGHT")
