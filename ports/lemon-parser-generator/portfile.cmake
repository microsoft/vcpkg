set(VCPKG_BUILD_TYPE release)
set(VCPKG_POLICY_EMPTY_INCLUDE_FOLDER enabled)

vcpkg_download_distfile(LEMON_C
    URLS "https://github.com/sqlite/sqlite/raw/version-${VERSION}/tool/lemon.c"
    FILENAME "lemon-${VERSION}.c"
    SHA512 ee4d939f024d56b6568383b921aecd65c9d6e148f4590dda767ff3024aafc99287543cdca68ba4e49700665ea0df2039e6d473110f92bee893b4477f5067bd91
)

vcpkg_download_distfile(LEMPAR_C
    URLS "https://github.com/sqlite/sqlite/raw/version-${VERSION}/tool/lempar.c"
    FILENAME "lempar-${VERSION}.c"
    SHA512 be59f09200f7918148d0701ffc9661601c6c7c40298948f07c64556af25af0708cf9eb4346d7a0d5af91fe4a9fd0c9337023823b89bc6a8449e70baaf17b00ca
)

set(SOURCE_PATH "${CURRENT_BUILDTREES_DIR}/src/${VERSION}")
file(REMOVE_RECURSE "${SOURCE_PATH}")
file(MAKE_DIRECTORY "${SOURCE_PATH}")
file(COPY_FILE "${LEMON_C}" "${SOURCE_PATH}/lemon.c")
file(COPY "${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt" DESTINATION "${SOURCE_PATH}")

vcpkg_cmake_configure(SOURCE_PATH "${SOURCE_PATH}")
vcpkg_cmake_install()

file(INSTALL "${LEMPAR_C}" DESTINATION "${CURRENT_PACKAGES_DIR}/tools/lemon" RENAME "lempar.c")

# same as sqlite3 port
file(WRITE "${CURRENT_PACKAGES_DIR}/share/${PORT}/copyright"
    "The author disclaims copyright to this source code.  In place of a legal notice,
here is a blessing:

    May you do good and not evil.
    May you find forgiveness for yourself and forgive others.
    May you share freely, never taking more than you give.
")
