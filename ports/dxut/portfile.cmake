include(${CMAKE_TRIPLET_FILE})
if (VCPKG_LIBRARY_LINKAGE STREQUAL static)
    message(FATAL_ERROR "Static building not supported yet")
endif()
include(vcpkg_common_functions)
set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/DXUT-sept2016)
vcpkg_download_distfile(ARCHIVE_FILE
    URLS "https://github.com/Microsoft/DXUT/archive/sept2016.tar.gz"
    FILENAME "DXUT-sept2016.tar.gz"
    SHA512 190006c194284a1f5d614477896b0469a59ece05dff37477dadbe98808a5c33e274c0c1bb1390f22d1b5e06c9f534f4b50d6002157b2a391e01c2192b8e08869
)
vcpkg_extract_source_archive(${ARCHIVE_FILE})

vcpkg_apply_patches(
    SOURCE_PATH ${SOURCE_PATH}
    PATCHES ${CMAKE_CURRENT_LIST_DIR}/dll.patch
)

vcpkg_build_msbuild(
    PROJECT_PATH ${SOURCE_PATH}/Core/DXUT_2015.vcxproj
)

IF (TRIPLET_SYSTEM_ARCH MATCHES "x86")
	SET(BUILD_ARCH "Win32")
ELSE()
	SET(BUILD_ARCH ${TRIPLET_SYSTEM_ARCH})
ENDIF()

file(INSTALL
	${SOURCE_PATH}/Core/DDSTextureLoader.h
	${SOURCE_PATH}/Core/DXErr.h
	${SOURCE_PATH}/Core/DXUT.h
	${SOURCE_PATH}/Core/DXUTDevice11.h
	${SOURCE_PATH}/Core/DXUTmisc.h
	${SOURCE_PATH}/Core/Screengrab.h
	${SOURCE_PATH}/Core/WICTextureLoader.h
    DESTINATION ${CURRENT_PACKAGES_DIR}/include
)

file(INSTALL
	${SOURCE_PATH}/Core/Bin/Desktop_2015/${BUILD_ARCH}/Release/DXUT.dll
	DESTINATION ${CURRENT_PACKAGES_DIR}/bin)

file(INSTALL
	${SOURCE_PATH}/Core/Bin/Desktop_2015/${BUILD_ARCH}/Release/DXUT.lib
	DESTINATION ${CURRENT_PACKAGES_DIR}/lib)

file(INSTALL
	${SOURCE_PATH}/Core/Bin/Desktop_2015/${BUILD_ARCH}/Debug/DXUT.dll
	DESTINATION ${CURRENT_PACKAGES_DIR}/debug/bin)

file(INSTALL
	${SOURCE_PATH}/Core/Bin/Desktop_2015/${BUILD_ARCH}/Debug/DXUT.lib
	DESTINATION ${CURRENT_PACKAGES_DIR}/debug/lib)

vcpkg_copy_pdbs()

file(INSTALL ${SOURCE_PATH}/MIT.txt DESTINATION ${CURRENT_PACKAGES_DIR}/share/dxut RENAME copyright)

message(STATUS "Installing done")
