vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO OSGeo/PROJ
    REF 6.3.1
    SHA512 ec5a2b61b12d3d3ec2456b9e742cf7be98767889c4759334e60276f609054fa8eb59f13f07af38e69e9ee7b6f2b9542e2d5d7806726ce5616062af4de626c6fa
    HEAD_REF master
    PATCHES
        fix-sqlite3-bin.patch
        disable-export-namespace.patch
        disable-projdb-with-arm-uwp.patch
        fix-win-output-name.patch
        fix-sqlite-dependency-export.patch
        fix-linux-build.patch
        use-sqlite3-config.patch
        tools-cmake.patch
)

if(VCPKG_LIBRARY_LINKAGE STREQUAL "dynamic")
  set(VCPKG_BUILD_SHARED_LIBS ON)
else()
  set(VCPKG_BUILD_SHARED_LIBS OFF)
endif()

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    database BUILD_PROJ_DATABASE
    tools BUILD_CCT
    tools BUILD_CS2CS
    tools BUILD_GEOD
    tools BUILD_GIE
    tools BUILD_PROJ
    tools BUILD_PROJINFO
)
if ("database" IN_LIST FEATURES)
    if (VCPKG_TARGET_IS_WINDOWS)
        set(BIN_SUFFIX .exe)
        if (EXISTS ${CURRENT_INSTALLED_DIR}/../x86-windows/tools/sqlite3.exe)
            set(SQLITE3_BIN_PATH ${CURRENT_INSTALLED_DIR}/../x86-windows/tools)
        elseif (EXISTS ${CURRENT_INSTALLED_DIR}/../x86-windows-static/tools/sqlite3.exe)
            set(SQLITE3_BIN_PATH ${CURRENT_INSTALLED_DIR}/../x86-windows-static/tools)
        elseif (EXISTS ${CURRENT_INSTALLED_DIR}/../x64-windows/tools/sqlite3.exe AND (NOT CMAKE_HOST_SYSTEM_PROCESSOR OR CMAKE_HOST_SYSTEM_PROCESSOR STREQUAL "x86_64"))
            set(SQLITE3_BIN_PATH ${CURRENT_INSTALLED_DIR}/../x64-windows/tools)
        elseif (EXISTS ${CURRENT_INSTALLED_DIR}/../x64-windows-static/tools/sqlite3.exe AND (NOT CMAKE_HOST_SYSTEM_PROCESSOR OR CMAKE_HOST_SYSTEM_PROCESSOR STREQUAL "x86_64"))
            set(SQLITE3_BIN_PATH ${CURRENT_INSTALLED_DIR}/../x64-windows-static/tools)
        elseif (NOT TRIPLET_SYSTEM_ARCH STREQUAL "arm" AND EXISTS ${CURRENT_INSTALLED_DIR}/tools/sqlite3.exe)
            set(SQLITE3_BIN_PATH ${CURRENT_INSTALLED_DIR}/tools)
        else()
            message(FATAL_ERROR "Proj4 database need to install sqlite3[tool]:x86-windows first.")
        endif()
    else()
        set(BIN_SUFFIX)
        set(SQLITE3_BIN_PATH ${CURRENT_INSTALLED_DIR}/tools)
    endif()
endif()

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS ${FEATURE_OPTIONS}
    -DBUILD_LIBPROJ_SHARED=${VCPKG_BUILD_SHARED_LIBS}
    -DPROJ_LIB_SUBDIR=lib
    -DPROJ_INCLUDE_SUBDIR=include
    -DPROJ_DATA_SUBDIR=share/proj4
    -DPROJ_TESTS=OFF
    -DEXE_SQLITE3=${SQLITE3_BIN_PATH}/sqlite3${BIN_SUFFIX}
)

vcpkg_install_cmake()
vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/proj4)
if ("tools" IN_LIST FEATURES)
    vcpkg_copy_tools(TOOL_NAMES cct cs2cs geod gie proj projinfo AUTO_CLEAN)
endif ()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)

file(INSTALL ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
