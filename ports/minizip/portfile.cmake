# When zlib updated, the minizip port should be updated at the same time
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO madler/zlib
    REF "v${VERSION}"
    SHA512 16fea4df307a68cf0035858abe2fd550250618a97590e202037acd18a666f57afc10f8836cbbd472d54a0e76539d0e558cb26f059d53de52ff90634bbf4f47d4
    HEAD_REF master
    PATCHES
        pkgconfig.patch          # https://github.com/madler/zlib/pull/1242
        install-tools.diff
        restore-32bit.diff       # somewhere in https://github.com/madler/zlib/pull/1233
        unofficial-iowin32.diff  # https://github.com/madler/zlib/pull/1243
        header-destination.diff  # for https://github.com/madler/zlib/issues/1252
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        bzip2               MINIZIP_ENABLE_BZIP2
        unofficial-iowin32  WITH_UNOFFICIAL_IOWIN32
    INVERTED_FEATURES
        tools               DISABLE_INSTALL_TOOLS
)

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "dynamic" MINIZIP_BUILD_SHARED)
string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "static" MINIZIP_BUILD_STATIC)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}/contrib/minizip"
    OPTIONS
        ${FEATURE_OPTIONS}
        -DMINIZIP_BUILD_SHARED=${MINIZIP_BUILD_SHARED}
        -DMINIZIP_BUILD_STATIC=${MINIZIP_BUILD_STATIC}
        -DMINIZIP_BUILD_TESTING=OFF
    OPTIONS_DEBUG
        -DDISABLE_INSTALL_TOOLS=ON
)
vcpkg_cmake_install()
vcpkg_copy_pdbs()
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/minizip)
vcpkg_fixup_pkgconfig()

if(VCPKG_TARGET_IS_WINDOWS)
    if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
        vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/lib/pkgconfig/minizip.pc" " -lminizip" " -lminizips")
    endif()
    if(NOT VCPKG_BUILD_TYPE)
        if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
            vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig/minizip.pc" " -lminizip" " -lminizipsd")
        else()
            vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig/minizip.pc" " -lminizip" " -lminizipd")
        endif()
    endif()
endif()

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/share/minizip/minizipConfig.cmake" [[_MINIZIP_supported_components "shared" "static"]] [[_MINIZIP_supported_components "static"]])
else()
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/share/minizip/minizipConfig.cmake" [[_MINIZIP_supported_components "shared" "static"]] [[_MINIZIP_supported_components "shared"]])
endif()

if("tools" IN_LIST FEATURES)
    vcpkg_copy_tools(TOOL_NAMES minizip miniunzip AUTO_CLEAN)
endif()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

file(COPY "${CMAKE_CURRENT_LIST_DIR}/unofficial-minizipConfig.cmake" DESTINATION "${CURRENT_PACKAGES_DIR}/share/unofficial-minizip")

file(COPY "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/contrib/minizip/MiniZip64_info.txt")
