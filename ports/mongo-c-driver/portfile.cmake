include(vcpkg_common_functions)
set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/mongo-c-driver-1.6.2)

vcpkg_download_distfile(ARCHIVE
    URLS "https://github.com/mongodb/mongo-c-driver/archive/1.6.2.tar.gz"
    FILENAME "mongo-c-driver-1.6.2.tar.gz"
    SHA512 3533fed665c70b71f0e9473156bab1575f60b0b3db412f19c0a625e1e35683a3077f96b8a0ba337fd755675029f47b68dc3a5fc8f39254bb0be589da57cffad3
)
vcpkg_extract_source_archive(${ARCHIVE})

vcpkg_apply_patches(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    PATCHES
        ${CMAKE_CURRENT_LIST_DIR}/bson.patch
        ${CMAKE_CURRENT_LIST_DIR}/fix-uwp.patch
)

set(ENABLE_SSL "WINDOWS")
if(VCPKG_CMAKE_SYSTEM_NAME STREQUAL "WindowsStore")
    set(ENABLE_SSL "OPENSSL")
endif()

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    OPTIONS
        -DBSON_ROOT_DIR=${CURRENT_INSTALLED_DIR}
        -DENABLE_TESTS=OFF
        -DENABLE_EXAMPLES=OFF
        -DENABLE_SSL=${ENABLE_SSL}
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
    file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/bin)
    file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/bin)
    file(REMOVE         ${CURRENT_PACKAGES_DIR}/lib/mongoc-1.0.lib)
    file(REMOVE         ${CURRENT_PACKAGES_DIR}/debug/lib/mongoc-1.0.lib)

    file(RENAME
        ${CURRENT_PACKAGES_DIR}/lib/mongoc-static-1.0.lib
        ${CURRENT_PACKAGES_DIR}/lib/mongoc-1.0.lib)
    file(RENAME
        ${CURRENT_PACKAGES_DIR}/debug/lib/mongoc-static-1.0.lib
        ${CURRENT_PACKAGES_DIR}/debug/lib/mongoc-1.0.lib)
else()
    file(REMOVE         ${CURRENT_PACKAGES_DIR}/lib/mongoc-static-1.0.lib)
    file(REMOVE         ${CURRENT_PACKAGES_DIR}/debug/lib/mongoc-static-1.0.lib)
endif()

file(INSTALL ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/mongo-c-driver RENAME copyright)
file(COPY ${SOURCE_PATH}/THIRD_PARTY_NOTICES DESTINATION ${CURRENT_PACKAGES_DIR}/share/mongo-c-driver)

vcpkg_copy_pdbs()
