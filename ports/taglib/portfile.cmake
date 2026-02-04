vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO taglib/taglib
    REF "v${VERSION}"
    SHA512 a762a61c6ebe677b84397aabb1873f16b53de7b2da63556804038266174ff01c34633071ea2fda4b3c4498d95a6c9ef7477dd2e4ce3b23f12129b517b110f82f
    HEAD_REF master
)

if(VCPKG_CMAKE_SYSTEM_NAME STREQUAL "WindowsStore")
    set(WINRT_OPTIONS -DHAVE_VSNPRINTF=1 -DPLATFORM_WINRT=1)
endif()

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DBUILD_TESTING=OFF
        -DBUILD_EXAMPLES=OFF
        ${WINRT_OPTIONS}
)
vcpkg_cmake_install()
vcpkg_fixup_pkgconfig()
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/taglib)

set(pcfile "${CURRENT_PACKAGES_DIR}/lib/pkgconfig/taglib.pc")
if(EXISTS "${pcfile}")
    vcpkg_replace_string("${pcfile}" "Requires: " "Requires: zlib" IGNORE_UNCHANGED)
    vcpkg_replace_string("${pcfile}" " -lz" "")
endif()
set(pcfile "${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig/taglib.pc")
if(EXISTS "${pcfile}")
    vcpkg_replace_string("${pcfile}" "Requires: " "Requires: zlib" IGNORE_UNCHANGED)
    vcpkg_replace_string("${pcfile}" " -lz" "")
endif()

# remove the debug/include files
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE "${CURRENT_PACKAGES_DIR}/bin/taglib-config.cmd" "${CURRENT_PACKAGES_DIR}/debug/bin/taglib-config.cmd") # Contains absolute paths

# remove bin directory for static builds (taglib creates a cmake batch file there)
if(VCPKG_LIBRARY_LINKAGE STREQUAL static)
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/include/taglib/taglib_export.h" "defined(TAGLIB_STATIC)" "1")
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/bin" "${CURRENT_PACKAGES_DIR}/debug/bin")
endif()

vcpkg_copy_pdbs()

# copyright file
file(COPY "${SOURCE_PATH}/COPYING.LGPL" DESTINATION "${CURRENT_PACKAGES_DIR}/share/taglib")
file(COPY "${SOURCE_PATH}/COPYING.MPL" DESTINATION "${CURRENT_PACKAGES_DIR}/share/taglib")
file(RENAME "${CURRENT_PACKAGES_DIR}/share/taglib/COPYING.LGPL" "${CURRENT_PACKAGES_DIR}/share/taglib/copyright")
