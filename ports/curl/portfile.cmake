include(${CMAKE_TRIPLET_FILE})
if (VCPKG_LIBRARY_LINKAGE STREQUAL static)
    message(FATAL_ERROR "Static building not supported yet")
endif()
include(vcpkg_common_functions)
set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/curl-curl-7_51_0)
vcpkg_download_distfile(ARCHIVE_FILE
    URLS "https://github.com/curl/curl/archive/curl-7_51_0.tar.gz"
    FILENAME "curl-7.51.0.tar.gz"
    SHA512 88ec572efb1b2fb793dc26b627e54863718e774343283f0eb92022ce252f7798332d9d3f20f63e45c38576614a000abbf12570e91e14a118f150e0378f1a27e5
)
vcpkg_extract_source_archive(${ARCHIVE_FILE})

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    OPTIONS
        -DBUILD_TESTING=OFF
        -DBUILD_CURL_EXE=OFF
        -DENABLE_MANUAL=OFF
    OPTIONS_DEBUG
        -DENABLE_DEBUG=ON
)

vcpkg_build_cmake()
vcpkg_install_cmake()

file(INSTALL ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/curl RENAME copyright)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
vcpkg_copy_pdbs()