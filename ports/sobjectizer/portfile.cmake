include(vcpkg_common_functions)

set(VERSION 5.5.24.2)
set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/so-${VERSION}/dev)

vcpkg_download_distfile(ARCHIVE
    URLS "https://sourceforge.net/projects/sobjectizer/files/sobjectizer/SObjectizer%20Core%20v.5.5/so-${VERSION}.zip"
    FILENAME "so-${VERSION}.zip"
    SHA512 50c80efc780850c394f3966f202ce45cde2cbef470ee6ead9c62239a1e9b60b28a970d8b217eca713b09118fbe4a8fc974a35f754d2f3ed395e2752bccd3e330
)
vcpkg_extract_source_archive(${ARCHIVE})

if(VCPKG_LIBRARY_LINKAGE STREQUAL static)
    set(SOBJECTIZER_BUILD_STATIC ON)
    set(SOBJECTIZER_BUILD_SHARED OFF)
else()
    set(SOBJECTIZER_BUILD_STATIC OFF)
    set(SOBJECTIZER_BUILD_SHARED ON)
endif()

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DSOBJECTIZER_BUILD_STATIC=${SOBJECTIZER_BUILD_STATIC}
        -DSOBJECTIZER_BUILD_SHARED=${SOBJECTIZER_BUILD_SHARED}
)

vcpkg_install_cmake()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
vcpkg_fixup_cmake_targets(CONFIG_PATH "lib/cmake/sobjectizer")

# Handle copyright
file(COPY ${SOURCE_PATH}/../LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/sobjectizer)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/sobjectizer/LICENSE ${CURRENT_PACKAGES_DIR}/share/sobjectizer/copyright)
