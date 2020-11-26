vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

if(NOT VCPKG_CRT_LINKAGE STREQUAL "dynamic")
  message(FATAL_ERROR "DXUT only supports dynamic CRT linkage")
endif()

vcpkg_download_distfile(ARCHIVE
    URLS "https://github.com/Microsoft/DXUT/archive/sept2016.tar.gz"
    FILENAME "DXUT-sept2016.tar.gz"
    SHA512 190006c194284a1f5d614477896b0469a59ece05dff37477dadbe98808a5c33e274c0c1bb1390f22d1b5e06c9f534f4b50d6002157b2a391e01c2192b8e08869
)

vcpkg_extract_source_archive_ex(
    OUT_SOURCE_PATH SOURCE_PATH
    ARCHIVE ${ARCHIVE}
)

IF (TRIPLET_SYSTEM_ARCH MATCHES "x86")
	SET(BUILD_ARCH "Win32")
ELSE()
	SET(BUILD_ARCH ${TRIPLET_SYSTEM_ARCH})
ENDIF()

vcpkg_build_msbuild(
    PROJECT_PATH ${SOURCE_PATH}/DXUT_2015.sln
	PLATFORM ${BUILD_ARCH}
)

file(INSTALL
	${SOURCE_PATH}/Core/
	${SOURCE_PATH}/Optional/
    DESTINATION ${CURRENT_PACKAGES_DIR}/include
	FILES_MATCHING PATTERN "*.h"
)
file(REMOVE_RECURSE
	${CURRENT_PACKAGES_DIR}/include/Bin)

file(INSTALL
	${SOURCE_PATH}/Core/Bin/Desktop_2015/${BUILD_ARCH}/Release/DXUT.lib
	${SOURCE_PATH}/Optional/Bin/Desktop_2015/${BUILD_ARCH}/Release/DXUTOpt.lib
	DESTINATION ${CURRENT_PACKAGES_DIR}/lib)

file(INSTALL
	${SOURCE_PATH}/Core/Bin/Desktop_2015/${BUILD_ARCH}/Debug/DXUT.lib
	${SOURCE_PATH}/Optional/Bin/Desktop_2015/${BUILD_ARCH}/Debug/DXUTOpt.lib
	DESTINATION ${CURRENT_PACKAGES_DIR}/debug/lib)

vcpkg_copy_pdbs()

file(INSTALL ${SOURCE_PATH}/MIT.txt DESTINATION ${CURRENT_PACKAGES_DIR}/share/dxut RENAME copyright)

message(STATUS "Installing done")
