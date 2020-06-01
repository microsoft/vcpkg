vcpkg_fail_port_install(ON_TARGET "Linux" "OSX" "UWP" "arm" "arm64")

vcpkg_check_linkage(ONLY_DYNAMIC_LIBRARY)

set(LOG4CXX_VERSION 0.10.0)
vcpkg_download_distfile(ARCHIVE
    URLS "https://archive.apache.org/dist/logging/log4cxx/0.10.0/apache-log4cxx-0.10.0.tar.gz"
    FILENAME "apache-log4cxx-0.10.0.tar.gz"
    SHA512 1c34d80983db5648bc4582ddcf6b4fdefdc6594c2769f95235f5441cd6d03cf279cc8f365e9a687085b113f79ebac9d7d33a54b6aa3b3b808c0e1a56a15ffa37
)

vcpkg_extract_source_archive_ex(
    OUT_SOURCE_PATH SOURCE_PATH
    ARCHIVE ${ARCHIVE}
    REF ${LOG4CXX_VERSION}
    PATCHES
        001_msvc.patch
)

file(COPY ${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt DESTINATION ${SOURCE_PATH})

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
)

vcpkg_install_cmake()

file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
