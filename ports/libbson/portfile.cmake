include(vcpkg_common_functions)
set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/libbson-1.6.2)

vcpkg_download_distfile(ARCHIVE
    URLS "https://github.com/mongodb/libbson/archive/1.6.2.tar.gz"
    FILENAME "libbson-1.6.2.tar.gz"
    SHA512 c5848984d5db5ab62e698a0185139b20834d83fd7befef72336997097f639ef13e81053531385e96c7ba1fe3f3fe4ded517f5b8ee58f0914c5c807a9cb43766d
)
vcpkg_extract_source_archive(${ARCHIVE})

vcpkg_apply_patches(
    SOURCE_PATH ${SOURCE_PATH}
    PATCHES ${CMAKE_CURRENT_LIST_DIR}/fix-uwp.patch
)

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    set(TARGET_TO_INSTALL bson_static)
else()
    set(TARGET_TO_INSTALL bson_shared)
endif()

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DENABLE_TESTS=OFF
        -DINSTALL_TARGETS=${TARGET_TO_INSTALL}
)

vcpkg_install_cmake()

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

vcpkg_copy_pdbs()