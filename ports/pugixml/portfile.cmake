include(vcpkg_common_functions)
set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/pugixml-1.8)
vcpkg_download_distfile(ARCHIVE
    URLS "https://github.com/zeux/pugixml/releases/download/v1.8.1/pugixml-1.8.1.zip"
    FILENAME "pugixml-1.8.1.zip"
    SHA512 683fe224a9bcac032d78cb44d03915a3766d2faa588f3a8486b5719f26eeba3e17d447edf70e1907f51f8649ffb4607b6badd1365e4c15cf24279bf577dc853e
)
vcpkg_extract_source_archive(${ARCHIVE})

if(VCPKG_LIBRARY_LINKAGE STREQUAL static)
	vcpkg_configure_cmake(
		SOURCE_PATH ${SOURCE_PATH}
	)
else()
	vcpkg_apply_patches(
		SOURCE_PATH ${SOURCE_PATH}
		PATCHES
			${CMAKE_CURRENT_LIST_DIR}/pugixmlapi.patch
	)
	vcpkg_configure_cmake(
		SOURCE_PATH ${SOURCE_PATH}
		OPTIONS
			-DBUILD_DEFINES="PUGIXML_API=__declspec\(dllexport\)"
	)
endif()

vcpkg_install_cmake()
vcpkg_copy_pdbs()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/lib/cmake)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/lib/cmake)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(INSTALL ${SOURCE_PATH}/readme.txt DESTINATION ${CURRENT_PACKAGES_DIR}/share/pugixml RENAME copyright)