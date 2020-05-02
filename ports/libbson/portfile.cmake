# This port needs to be updated at the same time as mongo-c-driver
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO mongodb/mongo-c-driver
    REF 99d422877c5b5ea52006c13ee3b48297251b2b2d # debian/1.16.1
    SHA512 e2f129439ff3697981774e0de35586a6afe98838acfc52d8a115bcb298350f2779b886dc6b27130e78b3b81f9b0a85b2bc6bcef246f9685c05f6789747c4739d
    HEAD_REF master
    PATCHES
        fix-uwp.patch
        fix-static-cmake.patch
)

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    set(ENABLE_STATIC ON)
else()
    set(ENABLE_STATIC OFF)
endif()

file(READ ${CMAKE_CURRENT_LIST_DIR}/CONTROL _contents)
string(REGEX MATCH "\nVersion:[ ]*[^ \n]+" _contents "${_contents}")
string(REGEX REPLACE ".+Version:[ ]*([\\.0-9]+).*" "\\1" BUILD_VERSION "${_contents}")

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DENABLE_MONGOC=OFF
        -DENABLE_BSON=ON
        -DENABLE_TESTS=OFF
        -DENABLE_EXAMPLES=OFF
        -DENABLE_STATIC=${ENABLE_STATIC}
        -DBUILD_VERSION=${BUILD_VERSION}
)

vcpkg_install_cmake()

vcpkg_copy_pdbs()

set(PORT_POSTFIX "1.0")

if (VCPKG_LIBRARY_LINKAGE STREQUAL static)
    vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/libbson-static-${PORT_POSTFIX} TARGET_PATH share/bson-${PORT_POSTFIX})
else()
    vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/libbson-${PORT_POSTFIX} TARGET_PATH share/bson-${PORT_POSTFIX})
endif()
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/share/mongo-c-driver)

# This rename is needed because the official examples expect to use #include <bson.h>
# See Microsoft/vcpkg#904
file(RENAME
    ${CURRENT_PACKAGES_DIR}/include/libbson-${PORT_POSTFIX}
    ${CURRENT_PACKAGES_DIR}/temp)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/include)
file(RENAME ${CURRENT_PACKAGES_DIR}/temp ${CURRENT_PACKAGES_DIR}/include)

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

if (VCPKG_LIBRARY_LINKAGE STREQUAL static)
    # drop the __declspec(dllimport) when building static
    vcpkg_replace_string(${CURRENT_PACKAGES_DIR}/include/bson/bson-macros.h
        "define BSON_API __declspec(dllimport)" "define BSON_API")
        
     file(RENAME ${CURRENT_PACKAGES_DIR}/share/bson-${PORT_POSTFIX}/libbson-static-${PORT_POSTFIX}-config.cmake
        ${CURRENT_PACKAGES_DIR}/share/bson-${PORT_POSTFIX}/bson-${PORT_POSTFIX}-config.cmake)
     file(RENAME ${CURRENT_PACKAGES_DIR}/share/bson-${PORT_POSTFIX}/libbson-static-${PORT_POSTFIX}-config-version.cmake
        ${CURRENT_PACKAGES_DIR}/share/bson-${PORT_POSTFIX}/bson-${PORT_POSTFIX}-config-version.cmake)

    file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/bin ${CURRENT_PACKAGES_DIR}/bin)
else()
     file(RENAME ${CURRENT_PACKAGES_DIR}/share/bson-${PORT_POSTFIX}/libbson-${PORT_POSTFIX}-config.cmake
        ${CURRENT_PACKAGES_DIR}/share/bson-${PORT_POSTFIX}/bson-${PORT_POSTFIX}-config.cmake)
     file(RENAME ${CURRENT_PACKAGES_DIR}/share/bson-${PORT_POSTFIX}/libbson-${PORT_POSTFIX}-config-version.cmake
        ${CURRENT_PACKAGES_DIR}/share/bson-${PORT_POSTFIX}/bson-${PORT_POSTFIX}-config-version.cmake)
endif()

vcpkg_replace_string(${CURRENT_PACKAGES_DIR}/share/bson-1.0/bson-1.0-config.cmake
    "include/libbson-1.0" "include/")

file(COPY ${SOURCE_PATH}/THIRD_PARTY_NOTICES DESTINATION ${CURRENT_PACKAGES_DIR}/share/libbson)

file(INSTALL ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
file(INSTALL ${CURRENT_PORT_DIR}/usage DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT})
