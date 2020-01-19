include(vcpkg_common_functions)

set(VERSION 5.6.1)

vcpkg_download_distfile(ARCHIVE
    URLS "https://sourceforge.net/projects/sobjectizer/files/sobjectizer/SObjectizer%20Core%20v.5.6/so-${VERSION}.tar.bz2"
    FILENAME "so-${VERSION}.tar.bz2"
    SHA512 f043a2d9025fe98d407023291100a79c2fbbd9d61e7c24602311e7383607b0fc1ec6108bfaea5f98021ebb942b3494f0380a2357bcaed01f92ede5dba0ab9cf0
)

vcpkg_extract_source_archive_ex(
    OUT_SOURCE_PATH SOURCE_PATH
    ARCHIVE ${ARCHIVE}
)

if(VCPKG_LIBRARY_LINKAGE STREQUAL static)
    set(SOBJECTIZER_BUILD_STATIC ON)
    set(SOBJECTIZER_BUILD_SHARED OFF)
else()
    set(SOBJECTIZER_BUILD_STATIC OFF)
    set(SOBJECTIZER_BUILD_SHARED ON)
endif()

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}/dev
    PREFER_NINJA
    OPTIONS
        -DSOBJECTIZER_BUILD_STATIC=${SOBJECTIZER_BUILD_STATIC}
        -DSOBJECTIZER_BUILD_SHARED=${SOBJECTIZER_BUILD_SHARED}
)

vcpkg_install_cmake()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/sobjectizer)

file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
