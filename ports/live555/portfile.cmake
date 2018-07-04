if(VCPKG_LIBRARY_LINKAGE STREQUAL "dynamic")
    message("live555 cannot currently be built dynamically. Building static instead.")
    set(VCPKG_LIBRARY_LINKAGE "static")
endif()

include(vcpkg_common_functions)
set(LIVE_VERSION 2018.07.01)
set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/${LIVE_VERSION}/live)
vcpkg_download_distfile(ARCHIVE
    URLS "http://www.live555.com/liveMedia/public/live.${LIVE_VERSION}.tar.gz"
    FILENAME "live.${LIVE_VERSION}.tar.gz"
    SHA512  b24ff9e4debdaf8848220d003627afc3860b9a34c7448f50d993900eb0241c63c9bc622be3e69b68e569607b4f6d174ab897d0e347f49d59842ac4f1b8f9c3ea
)
vcpkg_extract_source_archive(${ARCHIVE} ${CURRENT_BUILDTREES_DIR}/src/${LIVE_VERSION})

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
