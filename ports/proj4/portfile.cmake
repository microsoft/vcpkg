set(VERSION 7.2.1) # Variable used for pc file
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO OSGeo/PROJ
    REF "${VERSION}"
    SHA512 e6e77266dcd70c939c16667c916cccab8de161221d2ef600cfca43382f50da2dc8d790561556b4416adbb4ac6fba939004e0cc936c278e0e808dc3566e9a70d4
    HEAD_REF master
    PATCHES
        fix-filemanager-uwp.patch
        fix-sqlite3-bin.patch
        fix-win-output-name.patch
        fix-proj4-targets-cmake.patch
        tools-cmake.patch
)

if(VCPKG_LIBRARY_LINKAGE STREQUAL "dynamic")
  set(VCPKG_BUILD_SHARED_LIBS ON)
  set(EXTRA_FEATURES tiff ENABLE_TIFF tools BUILD_PROJSYNC tools ENABLE_CURL)
  set(TOOL_NAMES cct cs2cs geod gie proj projinfo projsync)
else()
  set(VCPKG_BUILD_SHARED_LIBS OFF)
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

set(PACKAGE "${PORT}")
set(requires_private "sqlite3")
if(ENABLE_CURL)
    string(APPEND requires_private " libcurl")
endif()
if(ENABLE_TIFF)
    string(APPEND requires_private " libtiff-4")
endif()
set(libs_private "")
if(VCPKG_TARGET_IS_WINDOWS AND NOT VCPKG_TARGET_IS_MINGW)
    string(APPEND libs_private " -lole32 -lshell32")
elseif(VCPKG_TARGET_IS_OSX)
    string(APPEND libs_private " -lc++ -lm")
else()
    string(APPEND libs_private " -lstdc++ -lm")
endif()
set(libdir [[${prefix}/lib]])
set(exec_prefix [[${prefix}]])
if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "release")
    set(includedir [[${prefix}/include]])
    set(datarootdir [[${prefix}/share]])
    set(datadir [[${prefix}/share]])
    set(outfile "${CURRENT_PACKAGES_DIR}/lib/pkgconfig/proj.pc")
    configure_file("${SOURCE_PATH}/proj.pc.in" "${outfile}" @ONLY)
    vcpkg_replace_string("${outfile}" "Requires:" "Requires.private: ${requires_private}")
    vcpkg_replace_string("${outfile}" " -lstdc++" "${libs_private}")
endif()
if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "debug")
    set(includedir [[${prefix}/../include]])
    set(datarootdir [[${prefix}/../share]])
    set(datadir [[${prefix}/../share]])
    set(outfile "${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig/proj.pc")
    configure_file("${SOURCE_PATH}/proj.pc.in" "${outfile}" @ONLY)
    vcpkg_replace_string("${outfile}" "Requires:" "Requires.private: ${requires_private}")
    vcpkg_replace_string("${outfile}" " -lstdc++" "${libs_private}")
    if(VCPKG_TARGET_IS_WINDOWS AND NOT VCPKG_TARGET_IS_MINGW)
        vcpkg_replace_string("${outfile}" " -lproj" " -lproj_d")
    endif()
endif()
vcpkg_fixup_pkgconfig()

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
file(INSTALL "${SOURCE_PATH}/COPYING" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
