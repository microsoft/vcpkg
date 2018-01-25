include(vcpkg_common_functions)
set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/libbson-1.9.2)

vcpkg_download_distfile(ARCHIVE
    URLS "https://github.com/mongodb/libbson/archive/1.9.2.tar.gz"
    FILENAME "libbson-1.9.2.tar.gz"
    SHA512 a05f1e8fbabb34e847692397e2e41fc5923ddd18dba861e5ab8a31acdf6738e13ab719eae8f9f8563f08fc43aab5c8d1f53cb6a47c38c96e132fa4a62a48d2bf
)
vcpkg_extract_source_archive(${ARCHIVE})

vcpkg_apply_patches(
    SOURCE_PATH ${SOURCE_PATH}
    PATCHES ${CMAKE_CURRENT_LIST_DIR}/fix-uwp.patch
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
        -DENABLE_TESTS=OFF
        -DENABLE_STATIC=${ENABLE_STATIC}
)

vcpkg_install_cmake()
if (VCPKG_LIBRARY_LINKAGE STREQUAL static)
    vcpkg_fixup_cmake_targets(CONFIG_PATH "lib/cmake/libbson-static-1.0")
else()
    vcpkg_fixup_cmake_targets(CONFIG_PATH "lib/cmake/libbson-1.0")
endif()

# This rename is needed because the official examples expect to use #include <bson.h>
# See Microsoft/vcpkg#904
file(RENAME
    ${CURRENT_PACKAGES_DIR}/include/libbson-1.0
    ${CURRENT_PACKAGES_DIR}/temp)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/include)
file(RENAME ${CURRENT_PACKAGES_DIR}/temp ${CURRENT_PACKAGES_DIR}/include)

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

if (VCPKG_LIBRARY_LINKAGE STREQUAL static)
    file(RENAME
        ${CURRENT_PACKAGES_DIR}/lib/bson-static-1.0.lib
        ${CURRENT_PACKAGES_DIR}/lib/bson-1.0.lib)
    file(RENAME
        ${CURRENT_PACKAGES_DIR}/debug/lib/bson-static-1.0.lib
        ${CURRENT_PACKAGES_DIR}/debug/lib/bson-1.0.lib)

    # drop the __declspec(dllimport) when building static
    vcpkg_apply_patches(
        SOURCE_PATH ${CURRENT_PACKAGES_DIR}/include
        PATCHES
            ${CMAKE_CURRENT_LIST_DIR}/static.patch
    )

    file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/bin ${CURRENT_PACKAGES_DIR}/bin)
endif()

file(INSTALL ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/libbson RENAME copyright)
file(COPY ${SOURCE_PATH}/THIRD_PARTY_NOTICES DESTINATION ${CURRENT_PACKAGES_DIR}/share/libbson)

if (VCPKG_LIBRARY_LINKAGE STREQUAL static)
    set(PORT_POSTFIX "static-1.0")
else()
    set(PORT_POSTFIX "1.0")
endif()

file(READ ${CURRENT_PACKAGES_DIR}/share/libbson/libbson-${PORT_POSTFIX}-config.cmake LIBBSON_CONFIG_CMAKE)
string(REPLACE "/include/libbson-1.0" "/include" LIBBSON_CONFIG_CMAKE "${LIBBSON_CONFIG_CMAKE}")
string(REPLACE "bson-static-1.0" "bson-1.0" LIBBSON_CONFIG_CMAKE "${LIBBSON_CONFIG_CMAKE}")
file(WRITE ${CURRENT_PACKAGES_DIR}/share/libbson/libbson-${PORT_POSTFIX}-config.cmake "${LIBBSON_CONFIG_CMAKE}")
file(COPY ${CURRENT_PACKAGES_DIR}/share/libbson/libbson-${PORT_POSTFIX}-config.cmake DESTINATION ${CURRENT_PACKAGES_DIR}/share/libbson-${PORT_POSTFIX})
file(COPY ${CURRENT_PACKAGES_DIR}/share/libbson/libbson-${PORT_POSTFIX}-config-version.cmake DESTINATION ${CURRENT_PACKAGES_DIR}/share/libbson-${PORT_POSTFIX})
file(RENAME ${CURRENT_PACKAGES_DIR}/share/libbson/libbson-${PORT_POSTFIX}-config.cmake ${CURRENT_PACKAGES_DIR}/share/libbson/libbson-config.cmake)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/libbson/libbson-${PORT_POSTFIX}-config-version.cmake ${CURRENT_PACKAGES_DIR}/share/libbson/libbson-config-version.cmake)

vcpkg_copy_pdbs()