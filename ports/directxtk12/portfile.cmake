include(vcpkg_common_functions)

vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

if(NOT VCPKG_CRT_LINKAGE STREQUAL "dynamic")
  message(FATAL_ERROR "DirectXTk12 only supports dynamic CRT linkage")
endif()

set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/DirectXTK12-dec2016)
vcpkg_download_distfile(ARCHIVE
    URLS "https://github.com/Microsoft/DirectXTK12/archive/dec2016.tar.gz"
    FILENAME "DirectXTK12-dec2016.tar.gz"
    SHA512 7c98fbf1d7ef96807a38d396a87dacdc60fdcd7e461210d246cc424789c4c5c5fb1390db958c1bd1f77da8af756a9eae36813e5da6bbb0ea1432ff4004f1d010
)
vcpkg_extract_source_archive(${ARCHIVE})

vcpkg_build_msbuild(
    PROJECT_PATH ${SOURCE_PATH}/DirectXTK_Desktop_2015_Win10.sln
)

IF (TRIPLET_SYSTEM_ARCH MATCHES "x86")
	SET(BUILD_ARCH "Win32")
ELSE()
	SET(BUILD_ARCH ${TRIPLET_SYSTEM_ARCH})
ENDIF()

file(INSTALL
	${SOURCE_PATH}/Bin/Desktop_2015_Win10/${BUILD_ARCH}/Release/DirectXTK12.lib
	DESTINATION ${CURRENT_PACKAGES_DIR}/lib)
file(INSTALL
	${SOURCE_PATH}/Bin/Desktop_2015_Win10/${BUILD_ARCH}/Debug/DirectXTK12.lib
	DESTINATION ${CURRENT_PACKAGES_DIR}/debug/lib)

file(INSTALL
	${SOURCE_PATH}/Inc/
    DESTINATION ${CURRENT_PACKAGES_DIR}/include/DirectXTK12
)

# Handle copyright
file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/directxtk12 RENAME copyright)
