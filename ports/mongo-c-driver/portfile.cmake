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
        disable-source-write.patch
        fix-include-directory.patch
        fix-static-cmake.patch
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
    "snappy" ENABLE_SNAPPY
    "icu"    ENABLE_ICU
)

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "static" ENABLE_STATIC)

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

file(READ "${CMAKE_CURRENT_LIST_DIR}/vcpkg.json" _contents)
string(JSON BUILD_VERSION GET "${_contents}" version)
file(WRITE "${SOURCE_PATH}/VERSION_CURRENT" "${BUILD_VERSION}")

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
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
    MAYBE_UNUSED_VARIABLES
        CMAKE_DISABLE_FIND_PACKAGE_PythonInterp
)

vcpkg_cmake_install()

vcpkg_copy_pdbs()

if (VCPKG_LIBRARY_LINKAGE STREQUAL static)
    vcpkg_cmake_config_fixup(CONFIG_PATH "lib/cmake/libmongoc-static-1.0" PACKAGE_NAME libmongoc-1.0)
else()
    vcpkg_cmake_config_fixup(CONFIG_PATH "lib/cmake/libmongoc-1.0" PACKAGE_NAME libmongoc-1.0)
endif()
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

if (VCPKG_LIBRARY_LINKAGE STREQUAL static)
    # drop the __declspec(dllimport) when building static
    vcpkg_replace_string(${CURRENT_PACKAGES_DIR}/include/mongoc/mongoc-macros.h
        "define MONGOC_API __declspec(dllimport)" "define MONGOC_API")

     file(RENAME
        "${CURRENT_PACKAGES_DIR}/share/libmongoc-1.0/libmongoc-static-1.0-config.cmake"
        "${CURRENT_PACKAGES_DIR}/share/libmongoc-1.0/libmongoc-1.0-config.cmake")
     file(RENAME
        "${CURRENT_PACKAGES_DIR}/share/libmongoc-1.0/libmongoc-static-1.0-config-version.cmake"
        "${CURRENT_PACKAGES_DIR}/share/libmongoc-1.0/libmongoc-1.0-config-version.cmake")

    file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/bin ${CURRENT_PACKAGES_DIR}/bin)
endif()

# Create cmake files for _both_ find_package(mongo-c-driver) and find_package(libmongoc-static-1.0)/find_package(libmongoc-1.0)
file(READ "${CURRENT_PACKAGES_DIR}/share/libmongoc-1.0/libmongoc-1.0-config.cmake" LIBMONGOC_CONFIG_CMAKE)

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

file(WRITE "${CURRENT_PACKAGES_DIR}/share/libmongoc-1.0/libmongoc-1.0-config.cmake" "${LIBMONGOC_CONFIG_CMAKE}")

file(COPY "${SOURCE_PATH}/THIRD_PARTY_NOTICES" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
file(INSTALL "${SOURCE_PATH}/COPYING" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
file(COPY "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
