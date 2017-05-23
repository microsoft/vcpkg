# Common Ambient Variables:
#   VCPKG_ROOT_DIR = <C:\path\to\current\vcpkg>
#   TARGET_TRIPLET is the current triplet (x86-windows, etc)
#   PORT is the current port name (zlib, etc)
#   CURRENT_BUILDTREES_DIR = ${VCPKG_ROOT_DIR}\buildtrees\${PORT}
#   CURRENT_PACKAGES_DIR  = ${VCPKG_ROOT_DIR}\packages\${PORT}_${TARGET_TRIPLET}
#

include(vcpkg_common_functions)
set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/fltk-1.3.4-1)
vcpkg_download_distfile(ARCHIVE
    URLS "http://fltk.org/pub/fltk/1.3.4/fltk-1.3.4-1-source.tar.gz"
    FILENAME "fltk.tar.gz"
    SHA512 0be1c8e6bb7a8c7ef484941a73868d5e40b90e97a8e5dc747bac2be53a350621975406ecfd4a9bcee8eeb7afd886e75bf7a6d6478fd6c56d16e54059f22f0891
)
vcpkg_extract_source_archive(${ARCHIVE})

vcpkg_apply_patches(
    SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/fltk-1.3.4-1
    PATCHES "${CMAKE_CURRENT_LIST_DIR}/findlibsfix.patch"
)

if (VCPKG_LIBRARY_LINKAGE STREQUAL dynamic)
    set(BUILD_SHARED ON)
else()
    set(BUILD_SHARED OFF)
endif()

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    OPTIONS 
        -DOPTION_BUILD_EXAMPLES=OFF
        -DOPTION_BUILD_SHARED_LIBS=${BUILD_SHARED}
)

vcpkg_install_cmake()

file(REMOVE_RECURSE
    ${CURRENT_PACKAGES_DIR}/CMAKE
    ${CURRENT_PACKAGES_DIR}/debug/CMAKE
    ${CURRENT_PACKAGES_DIR}/debug/include
)

file(COPY ${CURRENT_PACKAGES_DIR}/bin/fluid.exe DESTINATION ${CURRENT_PACKAGES_DIR}/tools)
file(REMOVE ${CURRENT_PACKAGES_DIR}/bin/fluid.exe)
file(REMOVE ${CURRENT_PACKAGES_DIR}/bin/fltk-config)

file(COPY ${CURRENT_PACKAGES_DIR}/debug/bin/fluid.exe DESTINATION ${CURRENT_PACKAGES_DIR}/tools/debug)
file(REMOVE ${CURRENT_PACKAGES_DIR}/debug/bin/fluid.exe)
file(REMOVE ${CURRENT_PACKAGES_DIR}/debug/bin/fltk-config)

vcpkg_copy_pdbs()

if (VCPKG_LIBRARY_LINKAGE STREQUAL dynamic)

	
else()
	file(REMOVE_RECURSE
		${CURRENT_PACKAGES_DIR}/debug/bin
		${CURRENT_PACKAGES_DIR}/bin
	)

   
endif()



file(INSTALL
    ${SOURCE_PATH}/COPYING
    DESTINATION ${CURRENT_PACKAGES_DIR}/share/fltk
    RENAME copyright
)
