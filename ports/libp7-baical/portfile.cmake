include(vcpkg_common_functions)

if(VCPKG_TARGET_ARCHITECTURE STREQUAL arm)
    message(FATAL_ERROR "libP7 does not support ARM")
endif()

if(VCPKG_CMAKE_SYSTEM_NAME STREQUAL "WindowsStore")
    message(FATAL_ERROR "libP7 does not support UWP")
endif()

set(LIBP7_VERSION 4.4)
set(LIBP7_HASH ce33db9a0c731e4dff95646703fe5fd96015f1c528377aa5dbe2e533529b0e8c45a4b74ee2b4616a811a7f9038c12edf106b08b3c21cec9cb6bdf85ad6e1d64f)
set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/libP7_v${LIBP7_VERSION})

vcpkg_download_distfile(ARCHIVE
    URLS "http://baical.net/files/libP7_v${LIBP7_VERSION}.zip"
    FILENAME "libP7_v${LIBP7_VERSION}.zip"
    SHA512 ${LIBP7_HASH}
)
vcpkg_extract_source_archive(${ARCHIVE} ${SOURCE_PATH})

file(COPY ${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt DESTINATION ${SOURCE_PATH})

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
)

vcpkg_build_cmake()
vcpkg_install_cmake()
vcpkg_copy_pdbs()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

file(COPY ${SOURCE_PATH}/License.txt DESTINATION ${CURRENT_PACKAGES_DIR}/share/libp7-baical/)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/libp7-baical/License.txt ${CURRENT_PACKAGES_DIR}/share/libp7-baical/copyright)