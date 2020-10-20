vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO freetds/freetds
    REF be39110fb1255843c18ee96d48c2aaa47f1ef2a7 # final 1.2 release
    HEAD_REF master
    SHA512 e981666190a0fa4424048505c6746bf1b768ec870b4032755b49af5730a3dfb18ff7bf566ddd939e30f46436145e2c57792c572d7afd7040f486e7c236a863df
    PATCHES
        fix-encoding-h-dependency.patch
        skip-unit-tests.patch
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        openssl WITH_OPENSSL
)

vcpkg_find_acquire_program(PERL)
get_filename_component(PERL_PATH ${PERL} DIRECTORY)
vcpkg_add_to_path(${PERL_PATH})

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
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
