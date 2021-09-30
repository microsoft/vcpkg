vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO OSGeo/PROJ
    REF 8.1.1
    SHA512 a26d4191905ac01ce8052290dbd065038bb59bdf5ee4ead0b8ba948de7fcc9d7bffd897533a07ffc2e9824b59210fa2a6cec652e512794a9ef9b07ce40e7e213
    HEAD_REF master
    PATCHES
        fix-filemanager-uwp.patch
        fix-win-output-name.patch
        fix-proj4-targets-cmake.patch
        tools-cmake.patch
        pkgconfig.patch
)

if(VCPKG_LIBRARY_LINKAGE STREQUAL "dynamic")
  set(EXTRA_FEATURES tiff ENABLE_TIFF tools BUILD_PROJSYNC tools ENABLE_CURL)
  set(TOOL_NAMES cct cs2cs geod gie proj projinfo projsync)
else()
  set(TOOL_NAMES cct cs2cs geod gie proj projinfo)
endif()

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        tools BUILD_CCT
        tools BUILD_CS2CS
        tools BUILD_GEOD
        tools BUILD_GIE
        tools BUILD_PROJ
        tools BUILD_PROJINFO
        ${EXTRA_FEATURES}
)

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
  message(WARNING "ENABLE_TIFF ENABLE_CURL and BUILD_PROJSYNC will be off when building static")
  set(FEATURE_OPTIONS ${FEATURE_OPTIONS} -DENABLE_TIFF=OFF -DENABLE_CURL=OFF -DBUILD_PROJSYNC=OFF)
endif()

set(EXE_SQLITE3 "${CURRENT_HOST_INSTALLED_DIR}/tools/sqlite3${VCPKG_HOST_EXECUTABLE_SUFFIX}")

vcpkg_cmake_configure(
    SOURCE_PATH ${SOURCE_PATH}
    OPTIONS ${FEATURE_OPTIONS}
    -DPROJ_LIB_SUBDIR=lib
    -DPROJ_INCLUDE_SUBDIR=include
    -DPROJ_DATA_SUBDIR=share/${PORT}
    -DBUILD_TESTING=OFF
    -DEXE_SQLITE3=${EXE_SQLITE3}
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(PACKAGE_NAME PROJ CONFIG_PATH lib/cmake/proj DO_NOT_DELETE_PARENT_CONFIG_PATH)
vcpkg_cmake_config_fixup(PACKAGE_NAME PROJ4 CONFIG_PATH lib/cmake/proj4)

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
