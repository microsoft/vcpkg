if (VCPKG_LIBRARY_LINKAGE STREQUAL dynamic)
    message(STATUS "Warning: Dynamic building not supported yet. Building static.")
    set(VCPKG_LIBRARY_LINKAGE static)
endif()

include(vcpkg_common_functions)
set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/DirectXTK12-oct2016)
vcpkg_download_distfile(ARCHIVE
    URLS "https://github.com/Microsoft/DirectXTK12/archive/oct2016.tar.gz"
    FILENAME "DirectXTK12-oct2016.tar.gz"
    SHA512 f33af80dc018c1fda117eeef66bd08046b48572806d879651187cbed9d5ceb402b1798ecc0e1089b54ddb879e5355b45f2b67e3be99fbe270c5216a945a9924b
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
