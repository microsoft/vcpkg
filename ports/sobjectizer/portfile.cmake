include(vcpkg_common_functions)

set(VERSION 5.5.19.2)
set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/so-${VERSION}/dev)

vcpkg_download_distfile(ARCHIVE
    URLS "https://downloads.sourceforge.net/project/sobjectizer/sobjectizer/SObjectizer%20Core%20v.5.5/so-${VERSION}.zip"
    FILENAME "so-${VERSION}.tar.xz"
    SHA512 8f70e751766ea43ddbc8e633aa729b81f01b84b7e3d4faf237e77a61dabe60bb1aaad8dabb868db4e473d801f5a639eb3d12aa8180feacb894f7a99b08375291
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

# patch SO_5_STATIC_LIB in headers with actual value
set(DECLSPEC_FILE ${CURRENT_PACKAGES_DIR}/include/so_5/h/declspec.hpp)
file(READ ${DECLSPEC_FILE} DECLSPEC_H)
if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    string(REPLACE "defined( SO_5_STATIC_LIB )" "1" DECLSPEC_H "${DECLSPEC_H}")
else()
    string(REPLACE "defined( SO_5_STATIC_LIB )" "0" DECLSPEC_H "${DECLSPEC_H}")
endif()
file(WRITE ${DECLSPEC_FILE} "${DECLSPEC_H}")

# Handle copyright
file(COPY ${SOURCE_PATH}/../LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/sobjectizer)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/sobjectizer/LICENSE ${CURRENT_PACKAGES_DIR}/share/sobjectizer/copyright)
