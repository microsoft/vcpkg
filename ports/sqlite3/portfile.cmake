include(${CMAKE_TRIPLET_FILE})
include(vcpkg_common_functions)
set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/sqlite-amalgamation-3150000)
vcpkg_download_distfile(ARCHIVE
    URLS "https://sqlite.org/2016/sqlite-amalgamation-3150000.zip"
    FILENAME "sqlite-amalgamation-3150000.zip"
    SHA512 82fea23b2158c448cbe2b80121eb32652df49eb85357edbaeef0c343ef478433706ebc4cd8add1985763db223d9268d0f7e74fc8db59353c15267cbc3d2078a8
)
vcpkg_extract_source_archive(${ARCHIVE})

file(COPY ${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt DESTINATION ${SOURCE_PATH})

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    OPTIONS
        -DSOURCE=${SOURCE_PATH}
)
vcpkg_build_cmake()
vcpkg_install_cmake()

file(WRITE ${CURRENT_PACKAGES_DIR}/share/sqlite3/copyright "SQLite is in the Public Domain.\nhttp://www.sqlite.org/copyright.html\n")
vcpkg_copy_pdbs()
