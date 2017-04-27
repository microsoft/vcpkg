# taglib

include(vcpkg_common_functions)
set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/taglib-1.11.1)
vcpkg_download_distfile(ARCHIVE
    URLS "http://taglib.org/releases/taglib-1.11.1.tar.gz"
    FILENAME "taglib-1.11.1.tar.gz"
    SHA512 7846775c4954ea948fe4383e514ba7c11f55d038ee06b6ea5a0a1c1069044b348026e76b27aa4ba1c71539aa8143e1401fab39184cc6e915ba0ae2c06133cb98
)
vcpkg_extract_source_archive(${ARCHIVE})

#patches for UWP
if(VCPKG_CMAKE_SYSTEM_NAME STREQUAL WindowsStore)
	vcpkg_apply_patches(
		SOURCE_PATH ${SOURCE_PATH}
		PATCHES 
			${CMAKE_CURRENT_LIST_DIR}/ignore_c4996_error.patch
			${CMAKE_CURRENT_LIST_DIR}/replace_non-uwp_functions.patch
	)
endif()

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    # OPTIONS -DUSE_THIS_IN_ALL_BUILDS=1 -DUSE_THIS_TOO=2
    # OPTIONS_RELEASE -DOPTIMIZE=1
    # OPTIONS_DEBUG -DDEBUGGABLE=1
)

vcpkg_install_cmake()

# remove the debug/include files
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

# copyright file
file(COPY ${CURRENT_PORT_DIR}/copyright DESTINATION ${CURRENT_PACKAGES_DIR}/share/taglib)

# remove bin directory for static builds (taglib creates a cmake batch file there)
if(VCPKG_LIBRARY_LINKAGE STREQUAL static)
    file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/bin ${CURRENT_PACKAGES_DIR}/debug/bin)
endif()
