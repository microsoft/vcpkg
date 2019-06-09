include(vcpkg_common_functions)

vcpkg_check_linkage(ONLY_STATIC_LIBRARY ONLY_DYNAMIC_CRT)

if(VCPKG_CMAKE_SYSTEM_NAME)
    message(FATAL_ERROR "UVAtlas only supports Windows Desktop")
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Microsoft/UVAtlas
    REF sept2016
    SHA512 326af26c151620cd5082daf3913cf3fbe7bca7d1aaf5cc44cacff54319ffe79b728c24519187c3f9393a846430d0fb9493ffe9473f87d220f5c9ae7dab73f69f
    HEAD_REF master
)

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

vcpkg_download_distfile(uvatlastool
    URLS "https://github.com/Microsoft/UVAtlas/releases/download/sept2016/uvatlastool.exe"
    FILENAME "uvatlastool.exe"
    SHA512 2583ba8179d0a58fb85d871368b17571e36242436b5a5dbaf6f99ec2f2ee09f4e11e8f922b29563da3cb3b5bacdb771036c84d5b94f405c7988bfe5f2881c3df
)

file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/tools/uvatlas/")

file(INSTALL
	${DOWNLOADS}/uvatlastool.exe
	DESTINATION ${CURRENT_PACKAGES_DIR}/tools/uvatlas/)

	# Handle copyright
file(COPY ${SOURCE_PATH}/MIT.txt DESTINATION ${CURRENT_PACKAGES_DIR}/share/uvatlas)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/uvatlas/MIT.txt ${CURRENT_PACKAGES_DIR}/share/uvatlas/copyright)
