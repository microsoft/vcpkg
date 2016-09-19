include(vcpkg_common_functions)
vcpkg_download_distfile(ARCHIVE
    URL "http://www.sqlite.org/2016/sqlite-amalgamation-3120200.zip"
    FILENAME "sqlite-amalgamation-3120200.zip"
    MD5 e3b10b952f075252169ac613068ccc97
)
vcpkg_extract_source_archive(${ARCHIVE})

vcpkg_configure_cmake(
    SOURCE_PATH ${CMAKE_CURRENT_LIST_DIR}
    OPTIONS
        -DSOURCE=${CURRENT_BUILDTREES_DIR}/src/sqlite-amalgamation-3120200
)

vcpkg_build_cmake()
vcpkg_install_cmake()

file(WRITE ${CURRENT_PACKAGES_DIR}/share/sqlite3/copyright "SQLite is in the Public Domain.\nhttp://www.sqlite.org/copyright.html\n")
vcpkg_copy_pdbs()
