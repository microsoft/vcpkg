include(vcpkg_common_functions)
set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/mongo-c-driver-1.9.0)

vcpkg_download_distfile(ARCHIVE
    URLS "https://github.com/mongodb/mongo-c-driver/archive/1.9.0.tar.gz"
    FILENAME "mongo-c-driver-1.9.0.tar.gz"
    SHA512 e7785f336c38bbf7dd519351bba2facab025b4d2bcd1eef82e98606a21510af7f799edaf4b4f074bd4c5a17ad63176c276f8c57e499b8d9afd098bce274da4ae
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

set(ENABLE_SSL "WINDOWS")
if(VCPKG_CMAKE_SYSTEM_NAME STREQUAL "WindowsStore")
    set(ENABLE_SSL "OPENSSL")
endif()

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DBSON_ROOT_DIR=${CURRENT_INSTALLED_DIR}
        -DENABLE_TESTS=OFF
        -DENABLE_EXAMPLES=OFF
        -DENABLE_SSL=${ENABLE_SSL}
        -DENABLE_STATIC=${ENABLE_STATIC}
)

vcpkg_install_cmake()

# This rename is needed because the official examples expect to use #include <mongoc.h>
# See Microsoft/vcpkg#904
file(RENAME
    ${CURRENT_PACKAGES_DIR}/include/libmongoc-1.0
    ${CURRENT_PACKAGES_DIR}/temp)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/include)
file(RENAME ${CURRENT_PACKAGES_DIR}/temp ${CURRENT_PACKAGES_DIR}/include)

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

if (VCPKG_LIBRARY_LINKAGE STREQUAL static)
    file(RENAME
        ${CURRENT_PACKAGES_DIR}/lib/mongoc-static-1.0.lib
        ${CURRENT_PACKAGES_DIR}/lib/mongoc-1.0.lib)
    file(RENAME
        ${CURRENT_PACKAGES_DIR}/debug/lib/mongoc-static-1.0.lib
        ${CURRENT_PACKAGES_DIR}/debug/lib/mongoc-1.0.lib)

    # drop the __declspec(dllimport) when building static
    vcpkg_apply_patches(
        SOURCE_PATH ${CURRENT_PACKAGES_DIR}/include
        PATCHES
            ${CMAKE_CURRENT_LIST_DIR}/static.patch
    )

    file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/bin ${CURRENT_PACKAGES_DIR}/bin)
endif()

file(INSTALL ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/mongo-c-driver RENAME copyright)
file(COPY ${SOURCE_PATH}/THIRD_PARTY_NOTICES DESTINATION ${CURRENT_PACKAGES_DIR}/share/mongo-c-driver)

if (VCPKG_LIBRARY_LINKAGE STREQUAL static)
file(READ ${CURRENT_PACKAGES_DIR}/lib/cmake/libmongoc-static-1.0/libmongoc-static-1.0-config.cmake LIBMONGOC_CONFIG_CMAKE)
string(REPLACE "/../../../" "/../../" LIBMONGOC_CONFIG_CMAKE "${LIBMONGOC_CONFIG_CMAKE}")
string(REPLACE "/include/libmongoc-1.0" "/include" LIBMONGOC_CONFIG_CMAKE "${LIBMONGOC_CONFIG_CMAKE}")
string(REPLACE "mongoc-static-1.0" "mongoc-1.0" LIBMONGOC_CONFIG_CMAKE "${LIBMONGOC_CONFIG_CMAKE}")
file(WRITE ${CURRENT_PACKAGES_DIR}/share/mongo-c-driver/mongo-c-driver-config.cmake "${LIBMONGOC_CONFIG_CMAKE}")
file(WRITE ${CURRENT_PACKAGES_DIR}/share/libmongoc-static-1.0/libmongoc-static-1.0-config.cmake "${LIBMONGOC_CONFIG_CMAKE}")
file(COPY ${CURRENT_PACKAGES_DIR}/lib/cmake/libmongoc-static-1.0/libmongoc-static-1.0-config-version.cmake DESTINATION ${CURRENT_PACKAGES_DIR}/share/mongo-c-driver)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/mongo-c-driver/libmongoc-static-1.0-config-version.cmake ${CURRENT_PACKAGES_DIR}/share/mongo-c-driver/mongo-c-driver-config-version.cmake)
file(COPY ${CURRENT_PACKAGES_DIR}/lib/cmake/libmongoc-static-1.0/libmongoc-static-1.0-config-version.cmake DESTINATION ${CURRENT_PACKAGES_DIR}/share/libmongoc-static-1.0)
else()
file(READ ${CURRENT_PACKAGES_DIR}/lib/cmake/libmongoc-1.0/libmongoc-1.0-config.cmake LIBMONGOC_CONFIG_CMAKE)
string(REPLACE "/../../../" "/../../" LIBMONGOC_CONFIG_CMAKE "${LIBMONGOC_CONFIG_CMAKE}")
string(REPLACE "/include/libmongoc-1.0" "/include" LIBMONGOC_CONFIG_CMAKE "${LIBMONGOC_CONFIG_CMAKE}")
file(WRITE ${CURRENT_PACKAGES_DIR}/share/mongo-c-driver/mongo-c-driver-config.cmake "${LIBMONGOC_CONFIG_CMAKE}")
file(WRITE ${CURRENT_PACKAGES_DIR}/share/libmongoc-1.0/libmongoc-1.0-config.cmake "${LIBMONGOC_CONFIG_CMAKE}")
file(COPY ${CURRENT_PACKAGES_DIR}/lib/cmake/libmongoc-1.0/libmongoc-1.0-config-version.cmake DESTINATION ${CURRENT_PACKAGES_DIR}/share/mongo-c-driver)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/mongo-c-driver/libmongoc-1.0-config-version.cmake ${CURRENT_PACKAGES_DIR}/share/mongo-c-driver/mongo-c-driver-config-version.cmake)
file(COPY ${CURRENT_PACKAGES_DIR}/lib/cmake/libmongoc-1.0/libmongoc-1.0-config-version.cmake DESTINATION ${CURRENT_PACKAGES_DIR}/share/libmongoc-1.0)
endif()
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/lib/cmake ${CURRENT_PACKAGES_DIR}/lib/cmake)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig ${CURRENT_PACKAGES_DIR}/lib/pkgconfig)

vcpkg_copy_pdbs()
