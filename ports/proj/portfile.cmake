vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO OSGeo/PROJ
    REF 65c84b6e2a40ec8e6b8d1de86bcd556d01ef2aeb # app. 9.0.0 RC2
    SHA512 9c9ed3272f2689dcd9b813632e669687cd34888dd4cd102be2b10e72d2756d5027effca19fb0682918b94a2d4f0abac1a3379ea078328c25e10bb92dc34583e6
    HEAD_REF master
    PATCHES
        fix-win-output-name.patch
        fix-proj4-targets-cmake.patch
        tools-cmake.patch
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        net   ENABLE_CURL
        tiff  ENABLE_TIFF
        tools BUILD_APPS
)

vcpkg_list(SET TOOL_NAMES cct cs2cs geod gie invgeod invproj proj projinfo projsync)
if("tools" IN_LIST FEATURES AND NOT "net" IN_LIST FEATURES)
    set(BUILD_PROJSYNC OFF)
    vcpkg_list(APPEND FEATURE_OPTIONS -DBUILD_PROJSYNC=${BUILD_PROJSYNC})
    vcpkg_list(REMOVE_ITEM TOOL_NAMES projsync)
endif()

find_program(EXE_SQLITE3 NAMES "sqlite3" PATHS "${CURRENT_HOST_INSTALLED_DIR}/tools" NO_DEFAULT_PATH REQUIRED)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        ${FEATURE_OPTIONS}
        -DNLOHMANN_JSON=external
        -DPROJ_LIB_SUBDIR=lib
        -DPROJ_INCLUDE_SUBDIR=include
        -DPROJ_DATA_SUBDIR=share/${PORT}/data
        -DBUILD_TESTING=OFF
        "-DEXE_SQLITE3=${EXE_SQLITE3}"
)

vcpkg_cmake_install()

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    # Enforce consistency with src/lib_proj.cmake build time configuration.
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/include/proj.h"
        "#ifndef PROJ_DLL"
        "#ifndef PROJ_DLL\n#  define PROJ_DLL\n#elif 0"
    )
endif()

vcpkg_cmake_config_fixup(PACKAGE_NAME proj4 CONFIG_PATH lib/cmake/proj4 DO_NOT_DELETE_PARENT_CONFIG_PATH)
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/proj)

if ("tools" IN_LIST FEATURES)
    vcpkg_copy_tools(TOOL_NAMES ${TOOL_NAMES} AUTO_CLEAN)
endif ()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

vcpkg_copy_pdbs()

vcpkg_fixup_pkgconfig()
if(NOT DEFINED VCPKG_BUILD_TYPE AND VCPKG_TARGET_IS_WINDOWS AND NOT VCPKG_TARGET_IS_MINGW)
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig/proj.pc" " -lproj" " -lproj_d")
endif()

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
file(INSTALL "${SOURCE_PATH}/COPYING" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
