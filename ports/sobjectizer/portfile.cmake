include(vcpkg_common_functions)

set(VERSION 5.5.20-beta1-201712061845)
set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/so-${VERSION}/dev)

vcpkg_download_distfile(ARCHIVE
    URLS "https://sourceforge.net/projects/sobjectizer/files/sobjectizer/SObjectizer%20Core%20v.5.5/so-${VERSION}.zip"
    FILENAME "so-${VERSION}.zip"
    SHA512 8b0dbec88d6783856cc75d8a71ae4b2c6620d77160c860ae1c6d16c1f8f8113dc4a86574a5ada6946444e8c8460c2a3861359a6c8743e1f98a93cea1871a6bb8
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
