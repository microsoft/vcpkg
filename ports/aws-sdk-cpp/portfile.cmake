include(vcpkg_common_functions)
set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/aws-sdk-cpp-1.0.61)
vcpkg_download_distfile(ARCHIVE
    URLS "https://github.com/aws/aws-sdk-cpp/archive/1.0.61.tar.gz"
    FILENAME "aws-sdk-cpp-1.0.61.tar.gz"
    SHA512 75f3570d8e8c08624b69d8254e156829030a36a7c4aa4b783d895e7c209b2a46b6b9ce822e6d9e9f649b171cf64988f0ad18ce0a55eb39c50d68a7880568078a
)
vcpkg_extract_source_archive(${ARCHIVE})

vcpkg_apply_patches(
    SOURCE_PATH ${SOURCE_PATH}
    PATCHES 
		${CMAKE_CURRENT_LIST_DIR}/drop_git.patch
		${CMAKE_CURRENT_LIST_DIR}/disable_warning_as_error.patch
)

if(VCPKG_CRT_LINKAGE STREQUAL static)
	set(FORCE_SHARED_CRT OFF)
else()
	set(FORCE_SHARED_CRT ON)
endif()

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
	PREFER_NINJA
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
	
	file(APPEND ${CURRENT_PACKAGES_DIR}/include/aws/core/SDKConfig.h "#define USE_IMPORT_EXPORT")
endif()

# Handle copyright
file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/aws-sdk-cpp RENAME copyright)
