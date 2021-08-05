vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO OSGeo/PROJ
    REF 8.0.0
    SHA512 353f0e14ba6c11bfcec8a30b3f322842e8a3103546e0fd40871e341c859ca7ae2b9411425be5b588eb45cc5716255d2ea81d6357407bcfb9506a0edb161376f5
    HEAD_REF master
    PATCHES
        fix-sqlite3-bin.patch
        disable-projdb-with-arm-uwp.patch
        fix-win-output-name.patch
        fix-proj4-targets-cmake.patch
        tools-cmake.patch
)

if(VCPKG_LIBRARY_LINKAGE STREQUAL "dynamic")
  set(VCPKG_BUILD_SHARED_LIBS ON)
else()
  set(VCPKG_BUILD_SHARED_LIBS OFF)
endif()
set(TOOL_NAMES cct cs2cs geod gie proj projinfo projsync)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
FEATURES
  database BUILD_PROJ_DATABASE
  tools BUILD_CCT
  tools BUILD_CS2CS
  tools BUILD_GEOD
  tools BUILD_GIE
  tools BUILD_PROJ
  tools BUILD_PROJINFO
  tools BUILD_PROJSYNC
  tools ENABLE_CURL
)

if ("database" IN_LIST FEATURES)
    set(EXE_SQLITE3 ${CURRENT_HOST_INSTALLED_DIR}/tools/sqlite3${VCPKG_HOST_EXECUTABLE_SUFFIX})
endif()

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS ${FEATURE_OPTIONS}
    -DPROJ_LIB_SUBDIR=lib
    -DPROJ_INCLUDE_SUBDIR=include
    -DPROJ_DATA_SUBDIR=share/${PORT}
    -DBUILD_TESTING=OFF
    -DEXE_SQLITE3=${EXE_SQLITE3}
)

vcpkg_install_cmake()
vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/${PORT})
if ("tools" IN_LIST FEATURES)
    vcpkg_copy_tools(TOOL_NAMES ${TOOL_NAMES} AUTO_CLEAN)
endif ()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)

file(INSTALL ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)

vcpkg_copy_pdbs()
