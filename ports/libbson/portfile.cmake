include(vcpkg_common_functions)
set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/libbson-1.9.0)

vcpkg_download_distfile(ARCHIVE
    URLS "https://github.com/mongodb/libbson/archive/1.9.0.tar.gz"
    FILENAME "libbson-1.9.0.tar.gz"
    SHA512 ced5e20a043096bbb2bd97f179c50fa105498fd089a54fcf7c0e3edda52030e7a6363ff1ab75c885649590a7d8846fa8adf880026cc059772cdfd87da23a244d
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
file(READ ${CURRENT_PACKAGES_DIR}/lib/cmake/libbson-static-1.0/libbson-static-1.0-config.cmake LIBBSON_CONFIG_CMAKE)
string(REPLACE "/../../../" "/../../" LIBBSON_CONFIG_CMAKE "${LIBBSON_CONFIG_CMAKE}")
string(REPLACE "/include/libbson-1.0" "/include" LIBBSON_CONFIG_CMAKE "${LIBBSON_CONFIG_CMAKE}")
string(REPLACE "bson-static-1.0" "bson-1.0" LIBBSON_CONFIG_CMAKE "${LIBBSON_CONFIG_CMAKE}")
file(WRITE ${CURRENT_PACKAGES_DIR}/share/libbson/libbson-config.cmake "${LIBBSON_CONFIG_CMAKE}")
file(WRITE ${CURRENT_PACKAGES_DIR}/share/libbson-static-1.0/libbson-static-1.0-config.cmake "${LIBBSON_CONFIG_CMAKE}")
file(COPY ${CURRENT_PACKAGES_DIR}/lib/cmake/libbson-static-1.0/libbson-static-1.0-config-version.cmake DESTINATION ${CURRENT_PACKAGES_DIR}/share/libbson)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/libbson/libbson-static-1.0-config-version.cmake ${CURRENT_PACKAGES_DIR}/share/libbson/libbson-config-version.cmake)
file(COPY ${CURRENT_PACKAGES_DIR}/lib/cmake/libbson-static-1.0/libbson-static-1.0-config-version.cmake DESTINATION ${CURRENT_PACKAGES_DIR}/share/libbson-static-1.0)
else()
file(READ ${CURRENT_PACKAGES_DIR}/lib/cmake/libbson-1.0/libbson-1.0-config.cmake LIBBSON_CONFIG_CMAKE)
string(REPLACE "/../../../" "/../../" LIBBSON_CONFIG_CMAKE "${LIBBSON_CONFIG_CMAKE}")
string(REPLACE "/include/libbson-1.0" "/include" LIBBSON_CONFIG_CMAKE "${LIBBSON_CONFIG_CMAKE}")
file(WRITE ${CURRENT_PACKAGES_DIR}/share/libbson/libbson-config.cmake "${LIBBSON_CONFIG_CMAKE}")
file(WRITE ${CURRENT_PACKAGES_DIR}/share/libbson-1.0/libbson-1.0-config.cmake "${LIBBSON_CONFIG_CMAKE}")
file(COPY ${CURRENT_PACKAGES_DIR}/lib/cmake/libbson-1.0/libbson-1.0-config-version.cmake DESTINATION ${CURRENT_PACKAGES_DIR}/share/libbson)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/libbson/libbson-1.0-config-version.cmake ${CURRENT_PACKAGES_DIR}/share/libbson/libbson-config-version.cmake)
file(COPY ${CURRENT_PACKAGES_DIR}/lib/cmake/libbson-1.0/libbson-1.0-config-version.cmake DESTINATION ${CURRENT_PACKAGES_DIR}/share/libbson-1.0)
endif()
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/lib/cmake ${CURRENT_PACKAGES_DIR}/lib/cmake)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig ${CURRENT_PACKAGES_DIR}/lib/pkgconfig)

vcpkg_copy_pdbs()