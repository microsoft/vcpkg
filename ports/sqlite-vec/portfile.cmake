vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO asg017/sqlite-vec
    REF "v${VERSION}"
    SHA512 1c51e3542823bc46385ef96edd4a0ca37e615458ba31e88515418e067bbaffc043e45b806d63bbb710fae905ec575555653f79e3a740188ebd210e9c6f8da4f8
    HEAD_REF main
    PATCHES
        fix-popcount.patch
)

file(COPY "${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt" DESTINATION "${SOURCE_PATH}")

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
)
vcpkg_cmake_install()
vcpkg_cmake_config_fixup(PACKAGE_NAME unofficial-sqlite-vec)

# The library is built into the application, so consumers use the regular SQLite API.
vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/include/sqlite-vec.h"
    "#ifndef SQLITE_CORE\n#include \"sqlite3ext.h\"\n#else\n#include \"sqlite3.h\"\n#endif"
    "#include \"sqlite3.h\""
)
vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/include/sqlite-vec.h"
    "#ifdef SQLITE_VEC_STATIC"
    "#if 1"
)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE-MIT" "${SOURCE_PATH}/LICENSE-APACHE")
