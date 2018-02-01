include(vcpkg_common_functions)
set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/mongo-c-driver-1.9.2)

vcpkg_download_distfile(ARCHIVE
    URLS "https://github.com/mongodb/mongo-c-driver/archive/1.9.2.tar.gz"
    FILENAME "mongo-c-driver-1.9.2.tar.gz"
    SHA512 a2c819da77aef93ce261093e98e8e8c41c449af56bd03d875e2838a067ae71b5ceb16fed2fb8df9458c84310451b813464377592806fc9ac39d9df2f4ddba83b
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
if (VCPKG_LIBRARY_LINKAGE STREQUAL static)
    vcpkg_fixup_cmake_targets(CONFIG_PATH "lib/cmake/libmongoc-static-1.0")
else()
    vcpkg_fixup_cmake_targets(CONFIG_PATH "lib/cmake/libmongoc-1.0")
endif()

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
    set(PORT_POSTFIX "static-1.0")
else()
    set(PORT_POSTFIX "1.0")
endif()

file(READ ${CURRENT_PACKAGES_DIR}/share/mongo-c-driver/libmongoc-${PORT_POSTFIX}-config.cmake LIBMONGOC_CONFIG_CMAKE)
string(REPLACE "/include/libmongoc-1.0" "/include" LIBMONGOC_CONFIG_CMAKE "${LIBMONGOC_CONFIG_CMAKE}")
string(REPLACE "mongoc-static-1.0" "mongoc-1.0" LIBMONGOC_CONFIG_CMAKE "${LIBMONGOC_CONFIG_CMAKE}")
file(WRITE ${CURRENT_PACKAGES_DIR}/share/mongo-c-driver/libmongoc-${PORT_POSTFIX}-config.cmake "${LIBMONGOC_CONFIG_CMAKE}")
file(COPY ${CURRENT_PACKAGES_DIR}/share/mongo-c-driver/libmongoc-${PORT_POSTFIX}-config.cmake DESTINATION ${CURRENT_PACKAGES_DIR}/share/libmongoc-${PORT_POSTFIX})
file(COPY ${CURRENT_PACKAGES_DIR}/share/mongo-c-driver/libmongoc-${PORT_POSTFIX}-config-version.cmake DESTINATION ${CURRENT_PACKAGES_DIR}/share/libmongoc-${PORT_POSTFIX})
file(RENAME ${CURRENT_PACKAGES_DIR}/share/mongo-c-driver/libmongoc-${PORT_POSTFIX}-config.cmake ${CURRENT_PACKAGES_DIR}/share/mongo-c-driver/mongo-c-driver-config.cmake)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/mongo-c-driver/libmongoc-${PORT_POSTFIX}-config-version.cmake ${CURRENT_PACKAGES_DIR}/share/mongo-c-driver/mongo-c-driver-config-version.cmake)

vcpkg_copy_pdbs()
