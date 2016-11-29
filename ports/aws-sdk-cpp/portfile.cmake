if (VCPKG_LIBRARY_LINKAGE STREQUAL static)
    message(STATUS "Warning: Static building not supported yet. Building dynamic.") #Blocked by CRT MD link issue.
    set(VCPKG_LIBRARY_LINKAGE dynamic)
endif()

include(vcpkg_common_functions)
set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/aws-sdk-cpp-1.0.34)
vcpkg_download_distfile(ARCHIVE
    URLS "https://github.com/aws/aws-sdk-cpp/archive/1.0.34.tar.gz"
    FILENAME "1.0.34.tar.gz"
    SHA512 21ca03eb323eecb55c29866b73c07956a36aad7c9c051eb7ca201cfd356c3f9732c89898cf0c89660d6c1279dc52438bb389b37d613bf741bae81bb3e773a3c5
)
vcpkg_extract_source_archive(${ARCHIVE})

vcpkg_apply_patches(
    SOURCE_PATH ${SOURCE_PATH}
    PATCHES 
		${CMAKE_CURRENT_LIST_DIR}/drop_git.patch
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
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

if(${VCPKG_LIBRARY_LINKAGE} STREQUAL dynamic)
	file(GLOB LIB_FILES          ${CURRENT_PACKAGES_DIR}/bin/*.lib)
	file(GLOB DEBUG_LIB_FILES    ${CURRENT_PACKAGES_DIR}/debug/bin/*.lib)
	file(COPY ${LIB_FILES}       DESTINATION ${CURRENT_PACKAGES_DIR}/lib)
	file(COPY ${DEBUG_LIB_FILES} DESTINATION ${CURRENT_PACKAGES_DIR}/debug/lib)
	file(REMOVE ${LIB_FILES} ${DEBUG_LIB_FILES})
endif()

# Handle copyright
file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/aws-sdk-cpp RENAME copyright)