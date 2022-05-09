vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO freetds/freetds
    REF 16f7a6280c7a19bfe5c60e5d61cc08e3f2dff991 # See https://github.com/microsoft/vcpkg/pull/14120#issuecomment-715896755
    HEAD_REF master
    SHA512 34ff10764156bac24444a74b636fafa56adc0097a62a3f3249d4bc09a0cdcaa88aa0c4f26761260c56dd47edf738ff68f647e045f32cac28e0be7f6760f7f90b
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        openssl WITH_OPENSSL
)

vcpkg_find_acquire_program(PERL)
get_filename_component(PERL_PATH ${PERL} DIRECTORY)
vcpkg_add_to_path(${PERL_PATH})

if (VCPKG_TARGET_IS_WINDOWS)
    vcpkg_find_acquire_program(GPERF)
    get_filename_component(GPERF_PATH ${GPERF} DIRECTORY)
    vcpkg_add_to_path(${GPERF_PATH})
else()
    if (NOT EXISTS /usr/bin/gperf)
        message(FATAL_ERROR "freetds requires gperf, these can be installed on Ubuntu systems via apt-get install gperf.")
    endif()
endif()

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    DISABLE_PARALLEL_CONFIGURE
    OPTIONS ${FEATURE_OPTIONS}
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

file(INSTALL ${SOURCE_PATH}/COPYING.txt DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
