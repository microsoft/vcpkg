include(vcpkg_common_functions)
set(SOURCE_PATH ${CMAKE_CURRENT_LIST_DIR})
vcpkg_download_distfile(ARCHIVE
    URLS "http://www.sqlite.org/2016/sqlite-amalgamation-3120200.zip"
    FILENAME "sqlite-amalgamation-3120200.zip"
    SHA512 92e1cc09dc4d4e9dd4c189e4a5061664f11971eb3e14c4c59e1f489f201411b08a31dae9e6fc50fffd49bb72f88ac3d99b7c7cd5e334b3079c165ee1c4f5a16e
)
vcpkg_extract_source_archive(${ARCHIVE})

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    OPTIONS
        -DSOURCE=${CURRENT_BUILDTREES_DIR}/src/sqlite-amalgamation-3120200
)

vcpkg_build_cmake()
vcpkg_install_cmake()

file(WRITE ${CURRENT_PACKAGES_DIR}/share/sqlite3/copyright "SQLite is in the Public Domain.\nhttp://www.sqlite.org/copyright.html\n")
vcpkg_copy_pdbs()
