if (VCPKG_LIBRARY_LINKAGE STREQUAL dynamic)
    message(STATUS "Warning: Dynamic building not supported yet. Building static.")
    set(VCPKG_LIBRARY_LINKAGE static)
endif()
if (VCPKG_CRT_LINKAGE STREQUAL static)
    message(FATAL_ERROR "UVAtlas does not currently support static crt linkage")
endif()
if(VCPKG_CMAKE_SYSTEM_NAME)
    message(FATAL_ERROR "UVAtlas only supports Windows Desktop")
endif()

include(vcpkg_common_functions)
set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/UVAtlas-sept2016)
vcpkg_download_distfile(ARCHIVE
    URLS "https://github.com/Microsoft/UVAtlas/archive/sept2016.tar.gz"
    FILENAME "UVAtlas-sept2016.tar.gz"
    SHA512 326af26c151620cd5082daf3913cf3fbe7bca7d1aaf5cc44cacff54319ffe79b728c24519187c3f9393a846430d0fb9493ffe9473f87d220f5c9ae7dab73f69f
)
vcpkg_extract_source_archive(${ARCHIVE})

IF(TRIPLET_SYSTEM_ARCH MATCHES "x86")
	SET(BUILD_ARCH "Win32")
ELSE()
	SET(BUILD_ARCH ${TRIPLET_SYSTEM_ARCH})
ENDIF()

vcpkg_build_msbuild(
    PROJECT_PATH ${SOURCE_PATH}/UVAtlas/UVAtlas_2015.sln
	PLATFORM ${BUILD_ARCH}
)

file(INSTALL
	${SOURCE_PATH}/UVAtlas/Inc/
    DESTINATION ${CURRENT_PACKAGES_DIR}/include)
file(INSTALL
	${SOURCE_PATH}/UVAtlas/Bin/Desktop_2015/${BUILD_ARCH}/Release/UVAtlas.lib
	DESTINATION ${CURRENT_PACKAGES_DIR}/lib)
file(INSTALL
	${SOURCE_PATH}/UVAtlas/Bin/Desktop_2015/${BUILD_ARCH}/Debug/UVAtlas.lib
	DESTINATION ${CURRENT_PACKAGES_DIR}/debug/lib)

# Handle copyright
file(COPY ${SOURCE_PATH}/MIT.txt DESTINATION ${CURRENT_PACKAGES_DIR}/share/uvatlas)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/uvatlas/MIT.txt ${CURRENT_PACKAGES_DIR}/share/uvatlas/copyright)

message(STATUS "Installing done, uvatlastool.exe can be downloaded at: ")
message(STATUS " https://github.com/Microsoft/UVAtlas/releases/download/sept2016/uvatlastool.exe")