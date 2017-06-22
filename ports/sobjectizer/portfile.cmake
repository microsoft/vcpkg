include(vcpkg_common_functions)

set(VERSION 5.5.19)
set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/so-${VERSION}/dev)

vcpkg_download_distfile(ARCHIVE
    URLS "https://downloads.sourceforge.net/project/sobjectizer/sobjectizer/SObjectizer%20Core%20v.5.5/so-${VERSION}.zip"
    FILENAME "so-${VERSION}.zip"
    SHA512 1dd5167e3a04a169f0d192504e64b2d7f0ce82322f4388207f15de21e31bf0a75f7b84efa406f0f84bea18235861479a169358e3a1b3bad6c3f7ffe5d33c502e
)
vcpkg_extract_source_archive(${ARCHIVE})

vcpkg_apply_patches(
    SOURCE_PATH ${SOURCE_PATH}
    PATCHES
        ${CMAKE_CURRENT_LIST_DIR}/001-cmake.patch 
)

if(VCPKG_LIBRARY_LINKAGE STREQUAL static)
    set(SO_BUILD_STATIC ON)
    set(SO_BUILD_SHARED OFF)
else()
    set(SO_BUILD_STATIC OFF)
    set(SO_BUILD_SHARED ON)
endif()

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DSO_BUILD_STATIC=${SO_BUILD_STATIC}
        -DSO_BUILD_SHARED=${SO_BUILD_SHARED}
)

vcpkg_install_cmake()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

# Handle copyright
file(COPY ${SOURCE_PATH}/../LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/sobjectizer)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/sobjectizer/LICENSE ${CURRENT_PACKAGES_DIR}/share/sobjectizer/copyright)
