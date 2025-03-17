vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO htacg/tidy-html5
    REF 5.8.0
    SHA512 f352165bdda5d1fca7bba3365560b64d6f70a4e010821cd246cde43bed5c23cea3408d461d3f889110fd35ec9b68aa2b4e95412b07775eb852b7ee1745007a44
    HEAD_REF master
    PATCHES
        disable-doc.patch
        static-vs-shared.patch
        debug-postfix.patch
        fix_unsupport_func_uwp.patch
        cmake_find_package_support.patch
)

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "dynamic" BUILD_SHARED_LIB)
vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    NO_CHARSET_FLAG
    OPTIONS
        -DBUILD_SHARED_LIB=${BUILD_SHARED_LIB}
        -DTIDY_CONSOLE_SHARED=${BUILD_SHARED_LIB}
)
vcpkg_cmake_install()
vcpkg_fixup_pkgconfig()
vcpkg_cmake_config_fixup(PACKAGE_NAME unofficial-tidy-html5 CONFIG_PATH lib/cmake/unofficial-tidy-html5)

file(REMOVE_RECURSE
    "${CURRENT_PACKAGES_DIR}/debug/include"
    "${CURRENT_PACKAGES_DIR}/debug/bin/tidyd${VCPKG_TARGET_EXECUTABLE_SUFFIX}"
)

vcpkg_copy_tools(TOOL_NAMES tidy AUTO_CLEAN)

file(INSTALL "${SOURCE_PATH}/README/LICENSE.md" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
