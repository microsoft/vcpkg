vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO copperspice/copperspice
    REF cs-${VERSION}
    SHA512 3eebaa8c50a440d1165eab1a72c9595b03779e11ce293ba61c35a0c4bed9b5b16908a19bd57af22c49294e84aa5f0c0dc4789d0590abdbb06c3cc77b89cfae31
    HEAD_REF master
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        gui         WITH_GUI
        multimedia  WITH_MULTIMEDIA
        network     WITH_NETWORK
        opengl      WITH_OPENGL
        script      WITH_SCRIPT
        sql         WITH_SQL
        svg         WITH_SVG
        vulkan      WITH_VULKAN
        webkit      WITH_WEBKIT
        xmlpatterns WITH_XMLPATTERNS
        # plugins
        psql        WITH_PSQL_PLUGIN
        mysql       WITH_MYSQL_PLUGIN
        odbc        WITH_ODBC_PLUGIN
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        ${FEATURE_OPTIONS}
        -DBUILD_TESTS=OFF
        -DCMAKE_DISABLE_FIND_PACKAGE_PostgreSQL=OFF
        -DCMAKE_DISABLE_FIND_PACKAGE_MySQL=OFF
        -DCMAKE_DISABLE_FIND_PACKAGE_ODBC=OFF
        -DCMAKE_DISABLE_FIND_PACKAGE_GTK2=ON
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH cmake/CopperSpice)

vcpkg_copy_pdbs()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

file(MAKE_DIRECTORY ${CURRENT_PACKAGES_DIR}/tools/CopperSpice)
file(RENAME
    ${CURRENT_PACKAGES_DIR}/bin/lconvert.exe
    ${CURRENT_PACKAGES_DIR}/tools/CopperSpice/lconvert.exe
)
file(RENAME
    ${CURRENT_PACKAGES_DIR}/bin/lrelease.exe
    ${CURRENT_PACKAGES_DIR}/tools/CopperSpice/lrelease.exe
)
file(RENAME
    ${CURRENT_PACKAGES_DIR}/bin/lupdate.exe
    ${CURRENT_PACKAGES_DIR}/tools/CopperSpice/lupdate.exe
)
file(RENAME
    ${CURRENT_PACKAGES_DIR}/bin/rcc.exe
    ${CURRENT_PACKAGES_DIR}/tools/CopperSpice/rcc.exe
)
file(RENAME
    ${CURRENT_PACKAGES_DIR}/bin/uic.exe
    ${CURRENT_PACKAGES_DIR}/tools/CopperSpice/uic.exe
)
file(REMOVE
    ${CURRENT_PACKAGES_DIR}/debug/bin/lconvert.exe
    ${CURRENT_PACKAGES_DIR}/debug/bin/lrelease.exe
    ${CURRENT_PACKAGES_DIR}/debug/bin/lupdate.exe
    ${CURRENT_PACKAGES_DIR}/debug/bin/rcc.exe
    ${CURRENT_PACKAGES_DIR}/debug/bin/uic.exe
    ${CURRENT_PACKAGES_DIR}/include/QtCore/cs_build_info.h
)

if(WITH_SQL)
    if(WITH_PSQL_PLUGIN)
        file(RENAME
            ${CURRENT_PACKAGES_DIR}/lib/CsSqlPsql1.9.dll
            ${CURRENT_PACKAGES_DIR}/bin/CsSqlPsql1.9.dll
        )
        file(RENAME
            ${CURRENT_PACKAGES_DIR}/debug/lib/CsSqlPsql1.9.dll
            ${CURRENT_PACKAGES_DIR}/debug/bin/CsSqlPsql1.9.dll
        )
    endif()
    if(WITH_MYSQL_PLUGIN)
        file(RENAME
            ${CURRENT_PACKAGES_DIR}/lib/CsSqlMySql1.9.dll
            ${CURRENT_PACKAGES_DIR}/bin/CsSqlMySql1.9.dll
        )
        file(RENAME
            ${CURRENT_PACKAGES_DIR}/debug/lib/CsSqlMySql1.9.dll
            ${CURRENT_PACKAGES_DIR}/debug/bin/CsSqlMySql1.9.dll
        )
    endif()
    if(WITH_ODBC_PLUGIN)
        file(RENAME
            ${CURRENT_PACKAGES_DIR}/lib/CsSqlOdbc1.9.dll
            ${CURRENT_PACKAGES_DIR}/bin/CsSqlOdbc1.9.dll
        )
        file(RENAME
            ${CURRENT_PACKAGES_DIR}/debug/lib/CsSqlOdbc1.9.dll
            ${CURRENT_PACKAGES_DIR}/debug/bin/CsSqlOdbc1.9.dll
        )
    endif()
endif()

file(GLOB LICENSE_FILES "${SOURCE_PATH}/license/*")
vcpkg_install_copyright(FILE_LIST ${LICENSE_FILES})

file(INSTALL
    "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}"
)