include(vcpkg_common_functions)
set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/curl-curl-7_51_0)
vcpkg_download_distfile(ARCHIVE_FILE
    URLS "https://github.com/curl/curl/archive/curl-7_51_0.tar.gz"
    FILENAME "curl-7.51.0.tar.gz"
    SHA512 88ec572efb1b2fb793dc26b627e54863718e774343283f0eb92022ce252f7798332d9d3f20f63e45c38576614a000abbf12570e91e14a118f150e0378f1a27e5
)
vcpkg_extract_source_archive(${ARCHIVE_FILE})

vcpkg_apply_patches(
    SOURCE_PATH ${SOURCE_PATH}
    PATCHES
        ${CMAKE_CURRENT_LIST_DIR}/0001_cmake.patch
)

if (VCPKG_CRT_LINKAGE STREQUAL dynamic)
    SET(CURL_STATICLIB OFF)
else()
    SET(CURL_STATICLIB ON)
endif()

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    OPTIONS
        -DBUILD_TESTING=OFF
        -DBUILD_CURL_EXE=OFF
        -DENABLE_MANUAL=OFF
        -DCURL_STATICLIB=${CURL_STATICLIB}
    OPTIONS_DEBUG
        -DENABLE_DEBUG=ON
)

vcpkg_install_cmake()

file(INSTALL ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/curl RENAME copyright)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

if(VCPKG_LIBRARY_LINKAGE STREQUAL static)
    file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/bin ${CURRENT_PACKAGES_DIR}/debug/bin)
endif()

vcpkg_copy_pdbs()