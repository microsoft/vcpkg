if(VCPKG_LIBRARY_LINKAGE STREQUAL "dynamic")
    message("live555 cannot currently be built dynamically. Building static instead.")
    set(VCPKG_LIBRARY_LINKAGE "static")
endif()

include(vcpkg_common_functions)
set(LIVE_VERSION 2018.02.28)
set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/${LIVE_VERSION}/live)
vcpkg_download_distfile(ARCHIVE
    URLS "http://www.live555.com/liveMedia/public/live.${LIVE_VERSION}.tar.gz"
    FILENAME "live.${LIVE_VERSION}.tar.gz"
    SHA512 0e445d0b494d82e5826ecea2ec4196472781d3524d2fea95efef83ec5dc0d211334e3ea34dc83b758ed847e2b4290727b299b4118133ca2468911c7cb2053a55
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
