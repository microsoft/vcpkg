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
file(REMOVE ${CURRENT_PACKAGES_DIR}/bin/fluid.exe)
file(REMOVE ${CURRENT_PACKAGES_DIR}/bin/fltk-config)

file(REMOVE ${CURRENT_PACKAGES_DIR}/debug/bin/fluid.exe)
file(REMOVE ${CURRENT_PACKAGES_DIR}/debug/bin/fltk-config)
vcpkg_copy_pdbs()

if (VCPKG_LIBRARY_LINKAGE STREQUAL dynamic)
	file(RENAME ${CURRENT_PACKAGES_DIR}/debug/bin/libfltk_forms_SHAREDd.dll ${CURRENT_PACKAGES_DIR}/debug/bin/fltk_forms.dll)
	file(RENAME ${CURRENT_PACKAGES_DIR}/debug/bin/libfltk_gl_SHAREDd.dll ${CURRENT_PACKAGES_DIR}/debug/bin/fltk_gl.dll)
	file(RENAME ${CURRENT_PACKAGES_DIR}/debug/bin/libfltk_images_SHAREDd.dll ${CURRENT_PACKAGES_DIR}/debug/bin/fltk_images.dll)
	file(RENAME ${CURRENT_PACKAGES_DIR}/debug/bin/libfltk_SHAREDd.dll ${CURRENT_PACKAGES_DIR}/debug/bin/fltk.dll)
	
   	file(RENAME ${CURRENT_PACKAGES_DIR}/debug/bin/libfltk_forms_SHAREDd.pdb ${CURRENT_PACKAGES_DIR}/debug/bin/fltk_forms.pdb)
	file(RENAME ${CURRENT_PACKAGES_DIR}/debug/bin/libfltk_gl_SHAREDd.pdb ${CURRENT_PACKAGES_DIR}/debug/bin/fltk_gl.pdb)
	file(RENAME ${CURRENT_PACKAGES_DIR}/debug/bin/libfltk_images_SHAREDd.pdb ${CURRENT_PACKAGES_DIR}/debug/bin/fltk_images.pdb)
	file(RENAME ${CURRENT_PACKAGES_DIR}/debug/bin/libfltk_SHAREDd.pdb ${CURRENT_PACKAGES_DIR}/debug/bin/fltk.pdb)
	
	file(REMOVE ${CURRENT_PACKAGES_DIR}/debug/bin/fltk_formsd.lib)
	file(REMOVE ${CURRENT_PACKAGES_DIR}/debug/bin/fltk_gld.lib)
	file(REMOVE ${CURRENT_PACKAGES_DIR}/debug/bin/fltk_imagesd.lib)
	file(REMOVE ${CURRENT_PACKAGES_DIR}/debug/bin/fltkd.lib)
	   
	file(RENAME ${CURRENT_PACKAGES_DIR}/debug/lib/fltk_forms_SHAREDd.lib ${CURRENT_PACKAGES_DIR}/debug/lib/fltk_formsd.lib)
	file(RENAME ${CURRENT_PACKAGES_DIR}/debug/lib/fltk_gl_SHAREDd.lib ${CURRENT_PACKAGES_DIR}/debug/lib/fltk_gld.lib)
	file(RENAME ${CURRENT_PACKAGES_DIR}/debug/lib/fltk_images_SHAREDd.lib ${CURRENT_PACKAGES_DIR}/debug/lib/fltk_imagesd.lib)
	file(RENAME ${CURRENT_PACKAGES_DIR}/debug/lib/fltk_SHAREDd.lib ${CURRENT_PACKAGES_DIR}/debug/lib/fltkd.lib)
   
   	file(RENAME ${CURRENT_PACKAGES_DIR}/bin/libfltk_forms_SHARED.dll ${CURRENT_PACKAGES_DIR}/bin/fltk_forms.dll)
	file(RENAME ${CURRENT_PACKAGES_DIR}/bin/libfltk_gl_SHARED.dll ${CURRENT_PACKAGES_DIR}/bin/fltk_gl.dll)
	file(RENAME ${CURRENT_PACKAGES_DIR}/bin/libfltk_images_SHARED.dll ${CURRENT_PACKAGES_DIR}/bin/fltk_images.dll)
	file(RENAME ${CURRENT_PACKAGES_DIR}/bin/libfltk_SHARED.dll ${CURRENT_PACKAGES_DIR}/bin/fltk.dll)
	
	file(RENAME ${CURRENT_PACKAGES_DIR}/bin/libfltk_forms_SHARED.pdb ${CURRENT_PACKAGES_DIR}/bin/fltk_forms.pdb)
	file(RENAME ${CURRENT_PACKAGES_DIR}/bin/libfltk_gl_SHARED.pdb ${CURRENT_PACKAGES_DIR}/bin/fltk_gl.pdb)
	file(RENAME ${CURRENT_PACKAGES_DIR}/bin/libfltk_images_SHARED.pdb ${CURRENT_PACKAGES_DIR}/bin/fltk_images.pdb)
	file(RENAME ${CURRENT_PACKAGES_DIR}/bin/libfltk_SHARED.pdb ${CURRENT_PACKAGES_DIR}/bin/fltk.pdb)
	
	
	file(REMOVE ${CURRENT_PACKAGES_DIR}/lib/fltk_forms.lib)
	file(REMOVE ${CURRENT_PACKAGES_DIR}/lib/fltk_gl.lib)
	file(REMOVE ${CURRENT_PACKAGES_DIR}/lib/fltk_images.lib)
	file(REMOVE ${CURRENT_PACKAGES_DIR}/lib/fltk.lib)
	
	file(RENAME ${CURRENT_PACKAGES_DIR}/lib/fltk_forms_SHARED.lib ${CURRENT_PACKAGES_DIR}/lib/fltk_forms.lib)
	file(RENAME ${CURRENT_PACKAGES_DIR}/lib/fltk_gl_SHARED.lib ${CURRENT_PACKAGES_DIR}/lib/fltk_gl.lib)
	file(RENAME ${CURRENT_PACKAGES_DIR}/lib/fltk_images_SHARED.lib ${CURRENT_PACKAGES_DIR}/lib/fltk_images.lib)
	file(RENAME ${CURRENT_PACKAGES_DIR}/lib/fltk_SHARED.lib ${CURRENT_PACKAGES_DIR}/lib/fltk.lib)
	
else()
	file(REMOVE_RECURSE
		${CURRENT_PACKAGES_DIR}/debug/bin
		${CURRENT_PACKAGES_DIR}/bin
	)

   
endif()

file(RENAME ${CURRENT_PACKAGES_DIR}/debug/lib/fltk_formsd.lib ${CURRENT_PACKAGES_DIR}/debug/lib/fltk_forms.lib)
file(RENAME ${CURRENT_PACKAGES_DIR}/debug/lib/fltk_gld.lib ${CURRENT_PACKAGES_DIR}/debug/lib/fltk_gl.lib)
file(RENAME ${CURRENT_PACKAGES_DIR}/debug/lib/fltk_imagesd.lib ${CURRENT_PACKAGES_DIR}/debug/lib/fltk_images.lib)
file(RENAME ${CURRENT_PACKAGES_DIR}/debug/lib/fltkd.lib ${CURRENT_PACKAGES_DIR}/debug/lib/fltk.lib)



file(INSTALL
    ${SOURCE_PATH}/COPYING
    DESTINATION ${CURRENT_PACKAGES_DIR}/share/fltk
    RENAME copyright
)
