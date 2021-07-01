# This port needs to be updated at the same time as libbson
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO mongodb/mongo-c-driver
    REF 99d422877c5b5ea52006c13ee3b48297251b2b2d # debian/1.16.1
    SHA512 e2f129439ff3697981774e0de35586a6afe98838acfc52d8a115bcb298350f2779b886dc6b27130e78b3b81f9b0a85b2bc6bcef246f9685c05f6789747c4739d
    HEAD_REF master
    PATCHES
        fix-dependency-libbson.patch
        disable-static-when-dynamic-build.patch
        fix-arm-build.patch
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    "snappy" ENABLE_SNAPPY
    "icu"    ENABLE_ICU
)

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    set(ENABLE_STATIC ON)
else()
    set(ENABLE_STATIC OFF)
endif()

if(VCPKG_TARGET_IS_WINDOWS)
    set(ENABLE_SSL "WINDOWS")
else()
    set(ENABLE_SSL "OPENSSL")
endif()

if(VCPKG_TARGET_IS_ANDROID)
    set(ENABLE_SRV OFF)
    set(ENABLE_SHM_COUNTERS OFF)
else()
    set(ENABLE_SRV AUTO)
    set(ENABLE_SHM_COUNTERS AUTO)
endif()

file(READ ${CMAKE_CURRENT_LIST_DIR}/CONTROL _contents)
string(REGEX MATCH "\nVersion:[ ]*[^ \n]+" _contents "${_contents}")
string(REGEX REPLACE ".+Version:[ ]*([\\.0-9]+).*" "\\1" BUILD_VERSION "${_contents}")

file(WRITE "${BUILD_VERSION}" ${SOURCE_PATH}/VERSION_CURRENT)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DBSON_ROOT_DIR=${CURRENT_INSTALLED_DIR}
        -DENABLE_MONGOC=ON
        -DENABLE_BSON=SYSTEM
        -DENABLE_TESTS=OFF
        -DENABLE_EXAMPLES=OFF
        -DENABLE_SRV=${ENABLE_SRV}
        -DENABLE_SHM_COUNTERS=${ENABLE_SHM_COUNTERS}
        -DENABLE_SSL=${ENABLE_SSL}
        -DENABLE_ZLIB=SYSTEM
        -DENABLE_STATIC=${ENABLE_STATIC}
        -DBUILD_VERSION=${BUILD_VERSION}
        -DCMAKE_DISABLE_FIND_PACKAGE_PythonInterp=ON
        ${FEATURE_OPTIONS}
)

vcpkg_install_cmake()

vcpkg_copy_pdbs()

set(PORT_POSTFIX "1.0")

if (VCPKG_LIBRARY_LINKAGE STREQUAL static)
    vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/libmongoc-static-${PORT_POSTFIX} TARGET_PATH share/libmongoc-${PORT_POSTFIX})
else()
    vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/libmongoc-${PORT_POSTFIX} TARGET_PATH share/libmongoc-${PORT_POSTFIX})
endif()
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)

# This rename is needed because the official examples expect to use #include <mongoc.h>
# See Microsoft/vcpkg#904
file(RENAME
    ${CURRENT_PACKAGES_DIR}/include/libmongoc-${PORT_POSTFIX}
    ${CURRENT_PACKAGES_DIR}/temp)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/include)
file(RENAME ${CURRENT_PACKAGES_DIR}/temp ${CURRENT_PACKAGES_DIR}/include)

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

if (VCPKG_LIBRARY_LINKAGE STREQUAL static)
    if(NOT VCPKG_TARGET_IS_WINDOWS)
        if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "release")
            file(RENAME
                ${CURRENT_PACKAGES_DIR}/lib/libmongoc-static-1.0.a
                ${CURRENT_PACKAGES_DIR}/lib/libmongoc-1.0.a)
        endif()
        if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "debug")
            file(RENAME
                ${CURRENT_PACKAGES_DIR}/debug/lib/libmongoc-static-1.0.a
                ${CURRENT_PACKAGES_DIR}/debug/lib/libmongoc-1.0.a)
        endif()
    else()
        if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "release")
            file(RENAME
                ${CURRENT_PACKAGES_DIR}/lib/mongoc-static-1.0.lib
                ${CURRENT_PACKAGES_DIR}/lib/mongoc-1.0.lib)
        endif()
        if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "debug")
            file(RENAME
                ${CURRENT_PACKAGES_DIR}/debug/lib/mongoc-static-1.0.lib
                ${CURRENT_PACKAGES_DIR}/debug/lib/mongoc-1.0.lib)
        endif()
    endif()

    # drop the __declspec(dllimport) when building static
    vcpkg_replace_string(${CURRENT_PACKAGES_DIR}/include/mongoc/mongoc-macros.h
        "define MONGOC_API __declspec(dllimport)" "define MONGOC_API")

     file(RENAME ${CURRENT_PACKAGES_DIR}/share/libmongoc-${PORT_POSTFIX}/libmongoc-static-${PORT_POSTFIX}-config.cmake
        ${CURRENT_PACKAGES_DIR}/share/libmongoc-${PORT_POSTFIX}/libmongoc-${PORT_POSTFIX}-config.cmake)
     file(RENAME ${CURRENT_PACKAGES_DIR}/share/libmongoc-${PORT_POSTFIX}/libmongoc-static-${PORT_POSTFIX}-config-version.cmake
        ${CURRENT_PACKAGES_DIR}/share/libmongoc-${PORT_POSTFIX}/libmongoc-${PORT_POSTFIX}-config-version.cmake)

    file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/bin ${CURRENT_PACKAGES_DIR}/bin)
endif()

# Create cmake files for _both_ find_package(mongo-c-driver) and find_package(libmongoc-static-1.0)/find_package(libmongoc-1.0)
file(READ ${CURRENT_PACKAGES_DIR}/share/libmongoc-${PORT_POSTFIX}/libmongoc-${PORT_POSTFIX}-config.cmake LIBMONGOC_CONFIG_CMAKE)

# Patch: Set _IMPORT_PREFIX and replace PACKAGE_PREFIX_DIR
string(REPLACE
[[
get_filename_component(PACKAGE_PREFIX_DIR "${CMAKE_CURRENT_LIST_DIR}/../../" ABSOLUTE)
]]
[[
# VCPKG PATCH SET IMPORT_PREFIX
get_filename_component(_IMPORT_PREFIX "${CMAKE_CURRENT_LIST_FILE}" PATH)
get_filename_component(_IMPORT_PREFIX "${_IMPORT_PREFIX}" PATH)
get_filename_component(_IMPORT_PREFIX "${_IMPORT_PREFIX}" PATH)
if(_IMPORT_PREFIX STREQUAL "/")
  set(_IMPORT_PREFIX "")
endif()
]]
    LIBMONGOC_CONFIG_CMAKE "${LIBMONGOC_CONFIG_CMAKE}")
string(REPLACE [[PACKAGE_PREFIX_DIR]] [[_IMPORT_PREFIX]] LIBMONGOC_CONFIG_CMAKE "${LIBMONGOC_CONFIG_CMAKE}")

string(REPLACE "/include/libmongoc-1.0" "/include" LIBMONGOC_CONFIG_CMAKE "${LIBMONGOC_CONFIG_CMAKE}")
string(REPLACE "mongoc-static-1.0" "mongoc-1.0" LIBMONGOC_CONFIG_CMAKE "${LIBMONGOC_CONFIG_CMAKE}")
#Something similar is probably required for windows too!
if (NOT VCPKG_TARGET_IS_WINDOWS)
    string(REPLACE "/lib/libssl.a" "\$<\$<CONFIG:DEBUG>:/debug>/lib/libssl.a" LIBMONGOC_CONFIG_CMAKE "${LIBMONGOC_CONFIG_CMAKE}")
    string(REPLACE "/lib/libcrypto.a" "\$<\$<CONFIG:DEBUG>:/debug>/lib/libcrypto.a" LIBMONGOC_CONFIG_CMAKE "${LIBMONGOC_CONFIG_CMAKE}")
    string(REPLACE "/lib/libz.a" "\$<\$<CONFIG:DEBUG>:/debug>/lib/libz.a" LIBMONGOC_CONFIG_CMAKE "${LIBMONGOC_CONFIG_CMAKE}")
endif()

file(WRITE ${CURRENT_PACKAGES_DIR}/share/libmongoc-${PORT_POSTFIX}/libmongoc-${PORT_POSTFIX}-config.cmake "${LIBMONGOC_CONFIG_CMAKE}")

file(COPY ${SOURCE_PATH}/THIRD_PARTY_NOTICES DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT})
file(INSTALL ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
file(COPY ${CMAKE_CURRENT_LIST_DIR}/usage DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT})
