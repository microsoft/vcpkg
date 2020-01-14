vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO OSGeo/PROJ
    REF 6.3.0
    SHA512 603256c27fb73b82e9af245ad09b46e6bc6e1934cb6375bf476f8b63177e933fb210b932b6890c425722c509189a0323755e311466f226d64694013c6c4a52de
    HEAD_REF master
    PATCHES
        fix-sqlite3-bin.patch
        disable-export-namespace.patch
        disable-projdb-with-arm-uwp.patch
        fix-win-output-name.patch
        fix-sqlite-dependency-export.patch
        fix-linux-build.patch
)

if(VCPKG_LIBRARY_LINKAGE STREQUAL "dynamic")
  set(VCPKG_BUILD_SHARED_LIBS ON)
else()
  set(VCPKG_BUILD_SHARED_LIBS OFF)
endif()

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    database BUILD_PROJ_DATABASE
)

if ("database" IN_LIST FEATURES)
    if (VCPKG_TARGET_IS_WINDOWS)
        set(BIN_SUFFIX .exe)
        if (VCPKG_TARGET_ARCHITECTURE STREQUAL arm)
            if (NOT EXISTS ${CURRENT_INSTALLED_DIR}/../x86-windows/tools/sqlite3.exe)
                message(FATAL_ERROR "Proj4 database need to install sqlite3[tool]:x86-windows first.")
            endif()
            set(SQLITE3_BIN_PATH ${CURRENT_INSTALLED_DIR}/../x86-windows/tools)
        elseif (VCPKG_TARGET_ARCHITECTURE STREQUAL arm64 OR (VCPKG_TARGET_ARCHITECTURE STREQUAL x64 AND VCPKG_LIBRARY_LINKAGE STREQUAL dynamic))
            if (NOT EXISTS ${CURRENT_INSTALLED_DIR}/../x64-windows/tools/sqlite3.exe)
                message(FATAL_ERROR "Proj4 database need to install sqlite3[tool]:x64-windows first.")
            endif()
            set(SQLITE3_BIN_PATH ${CURRENT_INSTALLED_DIR}/../x64-windows/tools)
        else()
            set(SQLITE3_BIN_PATH ${CURRENT_INSTALLED_DIR}/tools)
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
    -DBUILD_CCT=OFF
    -DBUILD_CS2CS=OFF
    -DBUILD_GEOD=OFF
    -DBUILD_GIE=OFF
    -DBUILD_PROJ=OFF
    -DBUILD_PROJINFO=OFF
    -DPROJ_TESTS=OFF
    -DEXE_SQLITE3=${SQLITE3_BIN_PATH}/sqlite3${BIN_SUFFIX}
)

vcpkg_install_cmake()
vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/proj4)

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)

file(INSTALL ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
