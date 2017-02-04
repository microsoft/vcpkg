include(vcpkg_common_functions)
set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/aws-sdk-cpp-1.0.61)
vcpkg_download_distfile(ARCHIVE
    URLS "https://github.com/aws/aws-sdk-cpp/archive/1.0.61.tar.gz"
    FILENAME "aws-sdk-cpp-1.0.61.tar.gz"
    SHA512 aef0a85a32db24dc4fba0fc49c2533074580f3df628e787ff0808f03deea5dac42e19b1edc966706784e98cfed17a350c3eff4f222df7cc756065be56d1fc6a6
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