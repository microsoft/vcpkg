include(vcpkg_common_functions)

vcpkg_check_linkage(ONLY_STATIC_LIBRARY) 

if(NOT VCPKG_USE_HEAD_VERSION)
    # Live555 only makes the latest releases available for download on their site
    message(FATAL_ERROR "Live555 does not have persistent releases. Please re-run the installation with --head.")
endif()

include(vcpkg_common_functions)

set(LIVE_VERSION latest)

vcpkg_download_distfile(ARCHIVE
    URLS "http://www.live555.com/liveMedia/public/live555-${LIVE_VERSION}.tar.gz"
    FILENAME "live555-${LIVE_VERSION}.tar.gz"
    SKIP_SHA512
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

file(GLOB HEADERS
    "${SOURCE_PATH}/BasicUsageEnvironment/include/*.h*"
    "${SOURCE_PATH}/groupsock/include/*.h*"
    "${SOURCE_PATH}/liveMedia/include/*.h*"
    "${SOURCE_PATH}/UsageEnvironment/include/*.h*"
)

file(COPY ${HEADERS} DESTINATION ${CURRENT_PACKAGES_DIR}/include)
file(INSTALL ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/live555 RENAME copyright)

vcpkg_copy_pdbs()
