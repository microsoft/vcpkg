vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO htacg/tidy-html5
    REF d1b906991a7587688d384b648c55731f9be52506
    SHA512 ac1229f95db9ab6367d7650e27b87e76a0874e01c9d404e8c5fb75ba2761318218b658a4f7522188fda8008974393a333a8a5fbed8e3a472c98445f13e459ad5
    HEAD_REF master
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    NO_CHARSET_FLAG
    OPTIONS
        -DBUILD_SHARED_LIB=OFF
        -DTIDY_CONSOLE_SHARED=OFF
)
vcpkg_add_to_path("${CURRENT_HOST_INSTALLED_DIR}/tools/libxslt/bin")
vcpkg_cmake_install()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

file(REMOVE "${CURRENT_PACKAGES_DIR}/debug/bin/tidyd.exe")
file(REMOVE "${CURRENT_PACKAGES_DIR}/debug/bin/tidyd")

vcpkg_copy_tools(TOOL_NAMES tidy AUTO_CLEAN)

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/bin" "${CURRENT_PACKAGES_DIR}/debug/bin")
endif()

file(INSTALL "${SOURCE_PATH}/README/LICENSE.md" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

vcpkg_fixup_pkgconfig()
