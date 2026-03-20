if(VCPKG_LIBRARY_LINKAGE STREQUAL dynamic)
    set(SHARED_LIBRARY_PATCH "fix-shared-library.patch")
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO mm2/Little-CMS
    REF "lcms${VERSION}"
    SHA512 1e256b6b7c06800ad21a5cd35971f39963710cc086cf22bc91a86f6f736b2bfa63cb705ada4431b6eb25714fe16a0e562acf51da742503d590fc1dd665a58b54
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
