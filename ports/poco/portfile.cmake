include(vcpkg_common_functions)
set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/poco-1.7.6-all)

vcpkg_download_distfile(ARCHIVE
    URLS "https://pocoproject.org/releases/poco-1.7.6/poco-1.7.6-all.zip"
    FILENAME "poco-1.7.6-all.zip"
    SHA512 ed15c6ab69157d3caf3f5fcd861396ddbe3a98c1f3d513c2670e81601c176fb17549791836bd50014d9fb58aa3983e262312848f197e9c487af962cc27556df5
)
vcpkg_extract_source_archive(${ARCHIVE})

vcpkg_apply_patches(
    SOURCE_PATH ${SOURCE_PATH}
    PATCHES
		${CMAKE_CURRENT_LIST_DIR}/config_h.patch
)

if (VCPKG_LIBRARY_LINKAGE STREQUAL static)
	set(POCO_STATIC ON)
	set(POCO_MT     ON)
endif()

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
	OPTIONS
		-DPOCO_STATIC=${POCO_STATIC}
		-DPOCO_MT=${POCO_MT}
		
		-DFORCE_OPENSSL=ON
		-DENABLE_TESTS=OFF
		-DENABLE_MSVC_MP=ON
		-DPOCO_UNBUNDLED=OFF # OFF means: using internal copy of sqlite, libz, pcre, expat, ...
)

vcpkg_install_cmake()

file(MAKE_DIRECTORY ${CURRENT_PACKAGES_DIR}/tools)
file(RENAME ${CURRENT_PACKAGES_DIR}/bin/cpspc.exe ${CURRENT_PACKAGES_DIR}/tools/cpspc.exe)
file(RENAME ${CURRENT_PACKAGES_DIR}/bin/f2cpsp.exe ${CURRENT_PACKAGES_DIR}/tools/f2cpsp.exe)

if (VCPKG_LIBRARY_LINKAGE STREQUAL static)
	file(REMOVE_RECURSE 
		${CURRENT_PACKAGES_DIR}/bin
		${CURRENT_PACKAGES_DIR}/debug/bin)
endif()

file(REMOVE 
	${CURRENT_PACKAGES_DIR}/bin/cpspc.pdb
	${CURRENT_PACKAGES_DIR}/bin/f2cpsp.pdb
	${CURRENT_PACKAGES_DIR}/debug/bin/cpspc.exe
	${CURRENT_PACKAGES_DIR}/debug/bin/cpspc.pdb
	${CURRENT_PACKAGES_DIR}/debug/bin/f2cpsp.exe
	${CURRENT_PACKAGES_DIR}/debug/bin/f2cpsp.pdb)

file(REMOVE
	${CURRENT_PACKAGES_DIR}/bin/vcruntime140.dll
	${CURRENT_PACKAGES_DIR}/bin/msvcp140.dll
	${CURRENT_PACKAGES_DIR}/debug/bin/vcruntime140.dll
	${CURRENT_PACKAGES_DIR}/debug/bin/msvcp140.dll)

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/lib/cmake)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/lib/cmake)

# copy license
file(COPY ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/poco)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/poco/LICENSE ${CURRENT_PACKAGES_DIR}/share/poco/copyright)