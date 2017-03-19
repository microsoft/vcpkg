include(vcpkg_common_functions)
set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/gdcm-2.6.7)
vcpkg_download_distfile(ARCHIVE
    URLS "https://downloads.sourceforge.net/project/gdcm/gdcm 2.x/GDCM 2.6.7/gdcm-2.6.7.tar.gz"
    FILENAME "gdcm-2.6.7.tar.gz"
    SHA512 2eefad47e4d36038db8d120a91dc0a40816d045e3562c711b6dba7aec5788d4b08a00966bf4c82dc354cb1aa654bff4200afff022a42f2ab58bf7baafe69ff05
)
vcpkg_extract_source_archive(${ARCHIVE})
vcpkg_apply_patches(
    SOURCE_PATH ${SOURCE_PATH}
    PATCHES "${CMAKE_CURRENT_LIST_DIR}/gdcm-include-dir.patch"
)
if(VCPKG_LIBRARY_LINKAGE STREQUAL dynamic)
    set(GDCM_BUILD_SHARED_LIBS ON)
else()
    set(GDCM_BUILD_SHARED_LIBS OFF)
endif()
vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
	# PREFER_NINJA # Disable this option if project cannot be built with Ninja
	OPTIONS
		-DGDCM_BUILD_DOCBOOK_MANPAGES=OFF
		-DGDCM_BUILD_SHARED_LIBS=ON
		-DGDCM_USE_SYSTEM_EXPAT=ON
		-DGDCM_USE_SYSTEM_ZLIB=${GDCM_BUILD_SHARED_LIBS}
		${ADDITIONAL_OPTIONS}
)

vcpkg_install_cmake()

file(REMOVE_RECURSE 
	${CURRENT_PACKAGES_DIR}/debug/include
    ${CURRENT_PACKAGES_DIR}/debug/share
)

# Handle copyright
file(INSTALL ${SOURCE_PATH}/Copyright.txt DESTINATION ${CURRENT_PACKAGES_DIR}/share/gdcm2 RENAME copyright)

vcpkg_copy_pdbs()
