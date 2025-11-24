vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO OSGeo/PROJ
    REF "${VERSION}"
    SHA512 0899fbf37e9a51abd9a4ded90b5fc0500432b497e27e05b21c524935621098399120cf3151e8ee4637b79943bd7ee31cda75f064a7f9ef47de5199d96ca92aa4
    HEAD_REF master
    PATCHES
        fix-proj4-targets-cmake.patch
        remove_toolset_restriction.patch
        sqlite.diff
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        net   ENABLE_CURL
        tiff  ENABLE_TIFF
        tools BUILD_APPS
)

vcpkg_list(SET TOOL_NAMES cct cs2cs geod gie invgeod invproj proj projinfo projsync)
if("tools" IN_LIST FEATURES AND NOT "net" IN_LIST FEATURES)
    vcpkg_list(APPEND FEATURE_OPTIONS -DBUILD_PROJSYNC=OFF)
    vcpkg_list(REMOVE_ITEM TOOL_NAMES projsync)
endif()

find_program(EXE_SQLITE3 NAMES "sqlite3" PATHS "${CURRENT_HOST_INSTALLED_DIR}/tools" NO_DEFAULT_PATH REQUIRED)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        ${FEATURE_OPTIONS}
        -DNLOHMANN_JSON=external
        -DBUILD_TESTING=OFF
        -DBUILD_EXAMPLES=OFF
        "-DEXE_SQLITE3=${EXE_SQLITE3}"
        -DPROJ_DATA_ENV_VAR_TRIED_LAST=ON
        -DEMBED_PROJ_DATA_PATH=OFF
    OPTIONS_DEBUG
        -DBUILD_APPS=OFF
)

vcpkg_cmake_install()
vcpkg_copy_pdbs()
vcpkg_cmake_config_fixup(PACKAGE_NAME proj4 CONFIG_PATH lib/cmake/proj4 DO_NOT_DELETE_PARENT_CONFIG_PATH)
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/proj)
vcpkg_fixup_pkgconfig()

if(NOT DEFINED VCPKG_BUILD_TYPE AND VCPKG_TARGET_IS_WINDOWS AND NOT VCPKG_TARGET_IS_MINGW)
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig/proj.pc" " -lproj" " -lproj_d")
endif()

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    # Enforce consistency with src/lib_proj.cmake build time configuration.
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/include/proj.h"
        "#ifndef PROJ_DLL"
        "#ifndef PROJ_DLL\n#  define PROJ_DLL\n#elif 0"
    )
endif()

if ("tools" IN_LIST FEATURES)
    vcpkg_copy_tools(TOOL_NAMES ${TOOL_NAMES} AUTO_CLEAN)
endif ()

file(REMOVE_RECURSE
    "${CURRENT_PACKAGES_DIR}/debug/include"
    "${CURRENT_PACKAGES_DIR}/debug/share"
    "${CURRENT_PACKAGES_DIR}/share/doc"
    "${CURRENT_PACKAGES_DIR}/share/man"
)

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/COPYING")
