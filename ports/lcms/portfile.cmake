if(VCPKG_LIBRARY_LINKAGE STREQUAL dynamic)
    set(SHARED_LIBRARY_PATCH "fix-shared-library.patch")
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO mm2/Little-CMS
    REF "lcms${VERSION}"
    SHA512 5425973a2dfc627db39c7a2bb6e0ef0220d17cdc6e14e3e1c65953eef6bd9d17a7b69d7ed146e3bcd6568f59413c2f9b74a7cb301f25a8640a72ba3968ddefb6
    HEAD_REF master
    PATCHES
        ${SHARED_LIBRARY_PATCH}
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
