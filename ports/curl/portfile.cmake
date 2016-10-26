include(${CMAKE_TRIPLET_FILE})
if (VCPKG_LIBRARY_LINKAGE STREQUAL static)
    message(FATAL_ERROR "Static building not supported yet")
endif()
include(vcpkg_common_functions)
set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/curl-7.48.0)
vcpkg_download_distfile(ARCHIVE_FILE
    URLS "https://curl.haxx.se/download/curl-7.48.0.tar.bz2"
    FILENAME "curl-7.48.0.tar.bz2"
    SHA512 9bb554eaf4ccaced0fa9b38de4f381eab84b96c1aa07a45d83ddfd38a925044d0fe9fac517263f67f009d2294a31c33dedb2267defbab0cb14f96091bbed5f92
)
vcpkg_extract_source_archive(${ARCHIVE_FILE})

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    OPTIONS
        -DBUILD_CURL_TESTS=OFF
        -DBUILD_CURL_EXE=OFF
        -DENABLE_MANUAL=OFF
    OPTIONS_DEBUG
        -DENABLE_DEBUG=ON
)

vcpkg_install_cmake()

file(INSTALL ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/curl RENAME copyright)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
vcpkg_copy_pdbs()