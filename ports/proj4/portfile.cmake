vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO OSGeo/PROJ
    REF 7.1.1
    SHA512 78e51a054bdf87a2c815b4f83452b4e0ec2ca9a8375d8ef22325550ea1ff96a0ed3efb967c98853dbdda05331b181034ef0a09632957fecd7d52ef33aebc0ff4
    HEAD_REF master
    PATCHES
        fix-sqlite3-bin.patch
	fix_default_datadir.patch
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

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
	tool BUILD_CCT
	tool BUILD_CS2CS
	tool BUILD_GEOD
	tool BUILD_GIE
	tool BUILD_PROJ
	tool BUILD_PROJINFO
	tool BUILD_PROJSYNC
	)

if (VCPKG_TARGET_IS_WINDOWS AND VCPKG_LIBRARY_LINKAGE STREQUAL  "static")
	string(APPEND VCPKG_LINKER_FLAGS "ws2_32.lib wldap32.lib crypt32.lib")
endif()

vcpkg_configure_cmake( 
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS ${FEATURE_OPTIONS}
    -DBUILD_LIBPROJ_SHARED=${VCPKG_BUILD_SHARED_LIBS}
    -DPROJ_LIB_SUBDIR=lib
    -DPROJ_INCLUDE_SUBDIR=include
    -DPROJ_DATA_SUBDIR=${CURRENT_INSTALLED_DIR}/share/proj4
    -DPROJ_TESTS=OFF
    -DEXE_SQLITE3=${SQLITE3_BIN_PATH}/sqlite3${BIN_SUFFIX}
)

if (VCPKG_TARGET_ARCHITECTURE STREQUAL "arm" OR VCPKG_TARGET_ARCHITECTURE STREQUAL "arm64")
	#	Fix for arm/arm64 native builds on SBC boards with little RAM...
	vcpkg_install_cmake(DISABLE_PARALLEL)
else()
	vcpkg_install_cmake()
endif()

if ("tool" IN_LIST FEATURES)
	vcpkg_copy_tools(SEARCH_DIR ${CURRENT_PACKAGES_DIR}/bin/ TOOL_NAMES cct cs2cs geod gie proj projinfo projsync AUTO_CLEAN)
	file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/bin)
endif()

vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/proj4)

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)

if ("tool" IN_LIST FEATURES)
	file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/bin")
endif()

file(INSTALL ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
