vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO mongodb/mongo-c-driver
    REF 74c49d8bc215b12ed352d2e4ca7633f426103cdd # debian/1.16.1-1
    SHA512 be260f15e2bac233929b0fe3be4220c3ed1e403ccf464205ff3f0970dfc3a1e6b5693d1d3f4e3e4e1976423dfbce8e140f4d3531861af4d4893110f20938d603
    HEAD_REF master
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    "snappy" ENABLE_SNAPPY
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

file(READ ${CMAKE_CURRENT_LIST_DIR}/CONTROL _contents)
string(REGEX MATCH "\nVersion:[ ]*[^ \n]+" _contents "${_contents}")
string(REGEX REPLACE ".+Version:[ ]*([\\.0-9]+).*" "\\1" BUILD_VERSION "${_contents}")

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DBSON_ROOT_DIR=${CURRENT_INSTALLED_DIR}
        -DENABLE_MONGOC=ON
        -DENABLE_BSON=ON
        -DENABLE_TESTS=OFF
        -DENABLE_EXAMPLES=OFF
        -DENABLE_SSL=${ENABLE_SSL}
        -DENABLE_ZLIB=SYSTEM
        -DENABLE_STATIC=${ENABLE_STATIC}
        -DBUILD_VERSION=${BUILD_VERSION}
        ${FEATURE_OPTIONS}
)

vcpkg_install_cmake()

if (VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/libmongoc-static-1.0)
else()
    vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/libmongoc-1.0)
endif()
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)

# This rename is needed because the official examples expect to use #include <mongoc.h>
# See Microsoft/vcpkg#904
file(RENAME
    ${CURRENT_PACKAGES_DIR}/include/libmongoc-1.0
    ${CURRENT_PACKAGES_DIR}/temp)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/include)
file(RENAME ${CURRENT_PACKAGES_DIR}/temp ${CURRENT_PACKAGES_DIR}/include)

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

if (VCPKG_LIBRARY_LINKAGE STREQUAL static)
    if(VCPKG_CMAKE_SYSTEM_NAME AND NOT VCPKG_TARGET_IS_UWP)
        file(RENAME
            ${CURRENT_PACKAGES_DIR}/lib/libmongoc-static-1.0.a
            ${CURRENT_PACKAGES_DIR}/lib/libmongoc-1.0.a)
        file(RENAME
            ${CURRENT_PACKAGES_DIR}/debug/lib/libmongoc-static-1.0.a
            ${CURRENT_PACKAGES_DIR}/debug/lib/libmongoc-1.0.a)
    else()
        file(RENAME
            ${CURRENT_PACKAGES_DIR}/lib/mongoc-static-1.0.lib
            ${CURRENT_PACKAGES_DIR}/lib/mongoc-1.0.lib)
        file(RENAME
            ${CURRENT_PACKAGES_DIR}/debug/lib/mongoc-static-1.0.lib
            ${CURRENT_PACKAGES_DIR}/debug/lib/mongoc-1.0.lib)
    endif()

    # drop the __declspec(dllimport) when building static
    file(READ ${CURRENT_PACKAGES_DIR}/include/mongoc/mongoc-macros.h MONGOC_MACROS_H)
    string(REPLACE "define MONGOC_API __declspec(dllimport)" "define MONGOC_API" MONGOC_MACROS_H "${MONGOC_MACROS_H}")
    file(WRITE ${CURRENT_PACKAGES_DIR}/include/mongoc/mongoc-macros.h "${MONGOC_MACROS_H}")

    file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/bin ${CURRENT_PACKAGES_DIR}/bin)
endif()

configure_file(${SOURCE_PATH}/COPYING ${CURRENT_PACKAGES_DIR}/share/mongo-c-driver/copyright COPYONLY)
file(COPY ${SOURCE_PATH}/THIRD_PARTY_NOTICES DESTINATION ${CURRENT_PACKAGES_DIR}/share/mongo-c-driver)

if (VCPKG_LIBRARY_LINKAGE STREQUAL static)
    set(PORT_POSTFIX "static-1.0")
else()
    set(PORT_POSTFIX "1.0")
endif()

# Create cmake files for _both_ find_package(mongo-c-driver) and find_package(libmongoc-static-1.0)/find_package(libmongoc-1.0)
file(READ ${CURRENT_PACKAGES_DIR}/share/mongo-c-driver/libmongoc-${PORT_POSTFIX}-config.cmake LIBMONGOC_CONFIG_CMAKE)

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
string(REPLACE "/lib/libssl.a" "\$<\$<CONFIG:DEBUG>:/debug>/lib/libssl.a" LIBMONGOC_CONFIG_CMAKE "${LIBMONGOC_CONFIG_CMAKE}")
string(REPLACE "/lib/libcrypto.a" "\$<\$<CONFIG:DEBUG>:/debug>/lib/libcrypto.a" LIBMONGOC_CONFIG_CMAKE "${LIBMONGOC_CONFIG_CMAKE}")
string(REPLACE "/lib/libz.a" "\$<\$<CONFIG:DEBUG>:/debug>/lib/libz.a" LIBMONGOC_CONFIG_CMAKE "${LIBMONGOC_CONFIG_CMAKE}")

file(WRITE ${CURRENT_PACKAGES_DIR}/share/mongo-c-driver/libmongoc-${PORT_POSTFIX}-config.cmake "${LIBMONGOC_CONFIG_CMAKE}")
file(COPY ${CURRENT_PACKAGES_DIR}/share/mongo-c-driver/libmongoc-${PORT_POSTFIX}-config.cmake DESTINATION ${CURRENT_PACKAGES_DIR}/share/libmongoc-${PORT_POSTFIX})
file(COPY ${CURRENT_PACKAGES_DIR}/share/mongo-c-driver/libmongoc-${PORT_POSTFIX}-config-version.cmake DESTINATION ${CURRENT_PACKAGES_DIR}/share/libmongoc-${PORT_POSTFIX})
file(RENAME ${CURRENT_PACKAGES_DIR}/share/mongo-c-driver/libmongoc-${PORT_POSTFIX}-config.cmake ${CURRENT_PACKAGES_DIR}/share/mongo-c-driver/mongo-c-driver-config.cmake)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/mongo-c-driver/libmongoc-${PORT_POSTFIX}-config-version.cmake ${CURRENT_PACKAGES_DIR}/share/mongo-c-driver/mongo-c-driver-config-version.cmake)

vcpkg_copy_pdbs()

file(COPY ${CMAKE_CURRENT_LIST_DIR}/usage DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT})

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig/libbson-1.0.pc ${CURRENT_PACKAGES_DIR}/lib/pkgconfig/libbson-1.0.pc)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig/libbson-static-1.0.pc ${CURRENT_PACKAGES_DIR}/lib/pkgconfig/libbson-static-1.0.pc)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/lib/bson-1.0.lib ${CURRENT_PACKAGES_DIR}/lib/bson-1.0.lib)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/lib/bson-static-1.0.lib ${CURRENT_PACKAGES_DIR}/lib/bson-static-1.0.lib)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/bin/libbson-1.0.dll ${CURRENT_PACKAGES_DIR}/bin/libbson-1.0.dll)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/bin/libbson-1.0.pdb ${CURRENT_PACKAGES_DIR}/bin/libbson-1.0.pdb)
