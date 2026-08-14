set(VCPKG_BUILD_TYPE release)
set(VCPKG_POLICY_EMPTY_INCLUDE_FOLDER enabled)

vcpkg_download_distfile(LEMON_C
    URLS "https://github.com/sqlite/sqlite/raw/version-${VERSION}/tool/lemon.c"
    FILENAME "lemon-${VERSION}.c"
    SHA512 "baa6c01b9398f332fce35187cfcda5ba8fed8f20e49bdd53955b4e6d77a2d47eb382cf32696004e3b24b73e504de959e272a23a6983638330e760467f1b56957"
)

vcpkg_download_distfile(LEMPAR_C
    URLS "https://github.com/sqlite/sqlite/raw/version-${VERSION}/tool/lempar.c"
    FILENAME "lempar-${VERSION}.c"
    SHA512 "05fc35c854da1b597d5ebb781d81694d53af586a698bd4271b257b65ab2b8d97423823334d404eb051dd1a9fca04b0ae12a0bb47d09956934ae8993d7fc307c2"
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
