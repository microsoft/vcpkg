include(vcpkg_common_functions)
set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/aws-sdk-cpp-1.0.47)
vcpkg_download_distfile(ARCHIVE
    URLS "https://github.com/aws/aws-sdk-cpp/archive/1.0.47.tar.gz"
    FILENAME "aws-sdk-cpp-1.0.47.tar.gz"
    SHA512 ce7471bafe2763f1c382eed8afeaf6422058599a3aa11ae52909da668c45d12827fcd06b9b3ce34e3c2fa33297fd2e09421b8a89833d581efaf62b7108232acf
)
vcpkg_extract_source_archive(${ARCHIVE})

vcpkg_apply_patches(
    SOURCE_PATH ${SOURCE_PATH}
    PATCHES 
		${CMAKE_CURRENT_LIST_DIR}/drop_git.patch
)

if(VCPKG_CRT_LINKAGE STREQUAL static)
	set(FORCE_SHARED_CRT OFF)
else()
	set(FORCE_SHARED_CRT ON)
endif()

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
	OPTIONS
		-DENABLE_TESTING=OFF
		-DFORCE_SHARED_CRT=${FORCE_SHARED_CRT}
)

vcpkg_install_cmake()

file(REMOVE_RECURSE 
	${CURRENT_PACKAGES_DIR}/debug/include
	${CURRENT_PACKAGES_DIR}/lib/cmake
	${CURRENT_PACKAGES_DIR}/lib/pkgconfig
	${CURRENT_PACKAGES_DIR}/debug/lib/cmake
	${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig
	${CURRENT_PACKAGES_DIR}/nuget
	${CURRENT_PACKAGES_DIR}/debug/nuget)

if(VCPKG_LIBRARY_LINKAGE STREQUAL dynamic)
	file(GLOB LIB_FILES          ${CURRENT_PACKAGES_DIR}/bin/*.lib)
	file(GLOB DEBUG_LIB_FILES    ${CURRENT_PACKAGES_DIR}/debug/bin/*.lib)
	file(COPY ${LIB_FILES}       DESTINATION ${CURRENT_PACKAGES_DIR}/lib)
	file(COPY ${DEBUG_LIB_FILES} DESTINATION ${CURRENT_PACKAGES_DIR}/debug/lib)
	file(REMOVE ${LIB_FILES} ${DEBUG_LIB_FILES})
	
	vcpkg_apply_patches( #define USE_IMPORT_EXPORT in SDKConfig.h
		SOURCE_PATH ${CURRENT_PACKAGES_DIR}/include
		PATCHES 
			${CMAKE_CURRENT_LIST_DIR}/shared_define.patch
	)
endif()

# Handle copyright
file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/aws-sdk-cpp RENAME copyright)