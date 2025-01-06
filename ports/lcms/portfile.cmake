if(VCPKG_LIBRARY_LINKAGE STREQUAL dynamic)
    set(SHARED_LIBRARY_PATCH "fix-shared-library.patch")
endif()

vcpkg_download_distfile(ADD_MISSING_EXPORT_PATCH
    URLS https://github.com/mm2/Little-CMS/commit/f7b3c637c20508655f8b49935a4b556d52937b69.diff?full_index=1
    FILENAME Add-missing-export.patch
    SHA512 4a78f55c07fe5cef5fb9174d466672371283301df89e2825fc47d9fd4c526b291dce11d3896401a3284f4e2093e285c9e5ccbe0011e132576d189e70f66a1325
)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO mm2/Little-CMS
    REF "lcms${VERSION}"
    SHA512 c0d857123a0168cb76b5944a20c9e3de1cbe74e2b509fb72a54f74543e9c173474f09d50c495b0a0a295a3c2b47c5fa54a330d057e1a59b5a7e36d3f5a7f81b2
    HEAD_REF master
    PATCHES
        ${SHARED_LIBRARY_PATCH}
        ${ADD_MISSING_EXPORT_PATCH}
)

if("fastfloat" IN_LIST FEATURES)
    list(APPEND OPTIONS -Dfastfloat=true)
else()
    list(APPEND OPTIONS -Dfastfloat=false)
endif()
if("threaded" IN_LIST FEATURES)
    list(APPEND OPTIONS -Dthreaded=true)
else()
    list(APPEND OPTIONS -Dthreaded=false)
endif()
if("tools" IN_LIST FEATURES)
    list(APPEND OPTIONS -Dutils=true)
else()
    list(APPEND OPTIONS -Dutils=false)
endif()

vcpkg_configure_meson(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        ${OPTIONS}
        -Dsamples=false
)
vcpkg_install_meson()
vcpkg_fixup_pkgconfig()

if("tools" IN_LIST FEATURES)
    vcpkg_copy_tools(
        TOOL_NAMES jpgicc linkicc psicc tificc transicc
        AUTO_CLEAN
    )
endif()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/share/man")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/lcms-config.cmake" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/lcms2-config.cmake" DESTINATION "${CURRENT_PACKAGES_DIR}/share/lcms2")
file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
