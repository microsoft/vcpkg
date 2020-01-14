include(vcpkg_common_functions)

if(VCPKG_TARGET_ARCHITECTURE STREQUAL arm)
    message(FATAL_ERROR "libP7 does not support ARM")
endif()

if(VCPKG_CMAKE_SYSTEM_NAME STREQUAL "WindowsStore")
    message(FATAL_ERROR "libP7 does not support UWP")
endif()

set(LIBP7_VERSION 4.4)
set(LIBP7_HASH 500fefdf6fb01999ddb2accc8309cf8749fb7a65abb98faaf6d71a5ae3da4eac8c00c083905b01f7f6cc973387b605f2c4db0bb007562f76b7ad43b6abe2b91f)

vcpkg_download_distfile(ARCHIVE
    URLS "http://baical.net/files/libP7_v${LIBP7_VERSION}.zip"
    FILENAME "libP7_v${LIBP7_VERSION}.zip"
    SHA512 ${LIBP7_HASH}
)

vcpkg_extract_source_archive_ex(
    OUT_SOURCE_PATH SOURCE_PATH
    ARCHIVE ${ARCHIVE}
)

file(COPY ${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt DESTINATION ${SOURCE_PATH})

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
)

vcpkg_install_cmake()
vcpkg_copy_pdbs()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

file(COPY ${SOURCE_PATH}/License.txt DESTINATION ${CURRENT_PACKAGES_DIR}/share/libp7-baical/)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/libp7-baical/License.txt ${CURRENT_PACKAGES_DIR}/share/libp7-baical/copyright)