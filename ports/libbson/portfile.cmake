include(vcpkg_common_functions)
set(BUILD_VERSION 1.14.0)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO mongodb/mongo-c-driver
    REF ${BUILD_VERSION}
    SHA512 bf2bb835543dd2a445aac6cafa7bbbf90921ec41014534779924a5eb7cbd9fd532acd8146ce81dfcf1bcac33a78d8fce22b962ed7f776449e4357eccab8d6110
    HEAD_REF master
    PATCHES fix-uwp.patch
)

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    set(ENABLE_STATIC ON)
else()
    set(ENABLE_STATIC OFF)
endif()

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
if (VCPKG_LIBRARY_LINKAGE STREQUAL static)
    vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/libbson-static-1.0)
else()
    vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/libbson-1.0)
endif()
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/share/mongo-c-driver)

# This rename is needed because the official examples expect to use #include <bson.h>
# See Microsoft/vcpkg#904
file(RENAME
    ${CURRENT_PACKAGES_DIR}/include/libbson-1.0
    ${CURRENT_PACKAGES_DIR}/temp)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/include)
file(RENAME ${CURRENT_PACKAGES_DIR}/temp ${CURRENT_PACKAGES_DIR}/include)

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

if (VCPKG_LIBRARY_LINKAGE STREQUAL static)
    if(VCPKG_CMAKE_SYSTEM_NAME AND NOT VCPKG_CMAKE_SYSTEM_NAME STREQUAL "WindowsStore")
        file(RENAME
            ${CURRENT_PACKAGES_DIR}/lib/libbson-static-1.0.a
            ${CURRENT_PACKAGES_DIR}/lib/libbson-1.0.a)
        file(RENAME
            ${CURRENT_PACKAGES_DIR}/debug/lib/libbson-static-1.0.a
            ${CURRENT_PACKAGES_DIR}/debug/lib/libbson-1.0.a)
    else()
        file(RENAME
            ${CURRENT_PACKAGES_DIR}/lib/bson-static-1.0.lib
            ${CURRENT_PACKAGES_DIR}/lib/bson-1.0.lib)
        file(RENAME
            ${CURRENT_PACKAGES_DIR}/debug/lib/bson-static-1.0.lib
            ${CURRENT_PACKAGES_DIR}/debug/lib/bson-1.0.lib)
    endif()

    # drop the __declspec(dllimport) when building static
    vcpkg_apply_patches(
        SOURCE_PATH ${CURRENT_PACKAGES_DIR}/include
        PATCHES static.patch
    )

    file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/bin ${CURRENT_PACKAGES_DIR}/bin)
endif()

configure_file(${SOURCE_PATH}/COPYING ${CURRENT_PACKAGES_DIR}/share/libbson/copyright COPYONLY)
file(COPY ${SOURCE_PATH}/THIRD_PARTY_NOTICES DESTINATION ${CURRENT_PACKAGES_DIR}/share/libbson)

if (VCPKG_LIBRARY_LINKAGE STREQUAL static)
    set(PORT_POSTFIX "static-1.0")
else()
    set(PORT_POSTFIX "1.0")
endif()

# Create cmake files for _both_ find_package(libbson) and find_package(libbson-static-1.0)/find_package(libbson-1.0)
file(READ ${CURRENT_PACKAGES_DIR}/share/libbson/libbson-${PORT_POSTFIX}-config.cmake LIBBSON_CONFIG_CMAKE)
string(REPLACE "/include/libbson-1.0" "/include" LIBBSON_CONFIG_CMAKE "${LIBBSON_CONFIG_CMAKE}")
string(REPLACE "bson-static-1.0" "bson-1.0" LIBBSON_CONFIG_CMAKE "${LIBBSON_CONFIG_CMAKE}")
file(WRITE ${CURRENT_PACKAGES_DIR}/share/libbson/libbson-${PORT_POSTFIX}-config.cmake "${LIBBSON_CONFIG_CMAKE}")
file(COPY ${CURRENT_PACKAGES_DIR}/share/libbson/libbson-${PORT_POSTFIX}-config.cmake DESTINATION ${CURRENT_PACKAGES_DIR}/share/libbson-${PORT_POSTFIX})
file(COPY ${CURRENT_PACKAGES_DIR}/share/libbson/libbson-${PORT_POSTFIX}-config-version.cmake DESTINATION ${CURRENT_PACKAGES_DIR}/share/libbson-${PORT_POSTFIX})
file(RENAME ${CURRENT_PACKAGES_DIR}/share/libbson/libbson-${PORT_POSTFIX}-config.cmake ${CURRENT_PACKAGES_DIR}/share/libbson/libbson-config.cmake)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/libbson/libbson-${PORT_POSTFIX}-config-version.cmake ${CURRENT_PACKAGES_DIR}/share/libbson/libbson-config-version.cmake)

vcpkg_copy_pdbs()
