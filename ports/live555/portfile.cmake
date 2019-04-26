include(vcpkg_common_functions)

vcpkg_check_linkage(ONLY_STATIC_LIBRARY) 

# The current Live555 version from http://www.live555.com/liveMedia/public/live.2019.03.06
set(LIVE_VERSION 2019.04.24)

include(vcpkg_common_functions)
set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/${LIVE_VERSION}/live)
vcpkg_download_distfile(ARCHIVE
	URLS "http://www.live555.com/liveMedia/public/live.${LIVE_VERSION}.tar.gz"
	FILENAME "live555-${LIVE_VERSION}.tar.gz"
	SHA512 b92b8b515f8d6a6e5e92bc074aa77278668b4aa9d00d6f3cdc14fdfdc3f3a55ef0f9464b18532eed47ed5eabb604e8b03ccffb2502a7047b3b47969325d21ead
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


