include(vcpkg_common_functions)

vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

# The current Live555 version from http://www.live555.com/liveMedia/public/live.2019.03.06
set(LIVE_VERSION 2019.03.06)

include(vcpkg_common_functions)
set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/${LIVE_VERSION}/live)
vcpkg_download_distfile(ARCHIVE
	URLS "http://www.live555.com/liveMedia/public/live.${LIVE_VERSION}.tar.gz"
	FILENAME "live555-${LIVE_VERSION}.tar.gz"
	SHA512 cf3cbf57ec43d392fa82f06bd02f6d829208c9a9ec1c505d9eb6c5e2dd3393bbd8829b6216163deb8ea8356c180f30f610a639044a6941df5c9a92f29d4f1a75
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


