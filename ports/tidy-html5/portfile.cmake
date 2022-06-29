vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO htacg/tidy-html5
    REF 5.8.0
    SHA512 f352165bdda5d1fca7bba3365560b64d6f70a4e010821cd246cde43bed5c23cea3408d461d3f889110fd35ec9b68aa2b4e95412b07775eb852b7ee1745007a44
    HEAD_REF master
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    NO_CHARSET_FLAG
    OPTIONS
        -DBUILD_SHARED_LIB=OFF
        -DTIDY_CONSOLE_SHARED=OFF
)
vcpkg_add_to_path("${CURRENT_HOST_INSTALLED_DIR}/tools/libxslt")
vcpkg_cmake_install()
vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE
    "${CURRENT_PACKAGES_DIR}/debug/include"
    "${CURRENT_PACKAGES_DIR}/debug/share"
    "${CURRENT_PACKAGES_DIR}/debug/bin/tidyd${VCPKG_TARGET_EXECUTABLE_SUFFIX}"
)

vcpkg_copy_tools(TOOL_NAMES tidy AUTO_CLEAN)

file(INSTALL "${SOURCE_PATH}/README/LICENSE.md" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
