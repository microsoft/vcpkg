vcpkg_buildpath_length_warning(37)
if(VCPKG_TARGET_IS_WINDOWS)
    vcpkg_check_linkage(ONLY_STATIC_LIBRARY)
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO apache/avro
    REF 4e1fefca493029ace961b7ef8889a3722458565a #release-1.11.0
    SHA512 6e787983d68bc6ecffd14ca585917f695bc1ae554de9146a436d342f32321c3e7878cdfa32989742e682ac12a6eb914b3e3b515ca3164f386c0281c8b50b53ad
    HEAD_REF master
    PATCHES
        avro.patch          # Private vcpkg build fixes
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}/lang/c"
    OPTIONS
        -DBUILD_EXAMPLES=OFF
        -DBUILD_TESTS=OFF
        -DBUILD_DOCS=OFF
)

vcpkg_cmake_install()

vcpkg_copy_pdbs()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
# the files are broken and there is no way to fix it because the snappy dependency has no pkgconfig file
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/lib/pkgconfig" "${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig")

vcpkg_copy_tools(TOOL_NAMES avroappend avrocat AUTO_CLEAN)

if(NOT VCPKG_TARGET_IS_WINDOWS)
    vcpkg_copy_tools(TOOL_NAMES avropipe avromod AUTO_CLEAN)
endif()

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static" AND NOT VCPKG_TARGET_IS_WINDOWS)
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/bin" "${CURRENT_PACKAGES_DIR}/debug/bin")
endif()

file(INSTALL "${SOURCE_PATH}/lang/c/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
