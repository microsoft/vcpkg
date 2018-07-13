if(VCPKG_LIBRARY_LINKAGE STREQUAL "dynamic")
    message("live555 cannot currently be built dynamically. Building static instead.")
    set(VCPKG_LIBRARY_LINKAGE "static")
endif()

# The current Live555 version from http://www.live555.com/liveMedia/public/
set(LIVE_VERSION 2018.07.07)
set(LIVE_SHA e7d4ddf51e9666c6ebe9a46976035b68fea94be54825535ffb04006cd242b9d3ad08250305206442bed3500d1e8d628ccf44302c485f63a9e244b3f8b1e27fe4)

include(vcpkg_common_functions)
set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/${LIVE_VERSION}/live)
vcpkg_download_distfile(ARCHIVE
    URLS "http://www.live555.com/liveMedia/public/live.${LIVE_VERSION}.tar.gz"
    FILENAME "live.${LIVE_VERSION}.tar.gz"
    SHA512 ${LIVE_SHA}
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
