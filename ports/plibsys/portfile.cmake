include(vcpkg_common_functions)
set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/plibsys-0.0.3)
vcpkg_download_distfile(ARCHIVE_FILE
    URLS "https://github.com/saprykin/plibsys/archive/0.0.3.tar.gz"
    FILENAME "plibsys-0.0.3.tar.gz"
    SHA512 e2393fecb3e5feae81a4d60cd03e2ca17bc58453efaa5598beacdc5acedbc7c90374f9f851301fee08ace8dace843a2dff8c1c449cd457302363c98dd24e0415
)
vcpkg_extract_source_archive(${ARCHIVE_FILE})

if (VCPKG_CRT_LINKAGE STREQUAL dynamic)
    SET(PLIBSYS_STATIC OFF)
else()
    SET(PLIBSYS_STATIC ON)
endif()

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    OPTIONS
        -DPLIBSYS_TESTS=OFF
        -DPLIBSYS_COVERAGE=OFF
        -DPLIBSYS_BUILD_STATIC=${PLIBSYS_STATIC}
)

vcpkg_install_cmake()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

file(INSTALL ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/plibsys RENAME copyright)

if (VCPKG_LIBRARY_LINKAGE STREQUAL dynamic)
	set(PLIBSYS_FILENAME plibsys)

	# Put shared libraries into the proper directory
	file(MAKE_DIRECTORY ${CURRENT_PACKAGES_DIR}/bin)
	file(MAKE_DIRECTORY ${CURRENT_PACKAGES_DIR}/debug/bin)

    file(RENAME ${CURRENT_PACKAGES_DIR}/lib/plibsys.dll ${CURRENT_PACKAGES_DIR}/bin/plibsys.dll)
    file(RENAME ${CURRENT_PACKAGES_DIR}/debug/lib/plibsys.dll ${CURRENT_PACKAGES_DIR}/debug/bin/plibsys.dll)
else()
	set(PLIBSYS_FILENAME plibsysstatic)

	# For static build remove dynamic libraries
    file(REMOVE ${CURRENT_PACKAGES_DIR}/lib/plibsys.lib)
	file(REMOVE ${CURRENT_PACKAGES_DIR}/lib/plibsys.dll)
	file(REMOVE ${CURRENT_PACKAGES_DIR}/debug/lib/plibsys.lib)
	file(REMOVE ${CURRENT_PACKAGES_DIR}/debug/lib/plibsys.dll)
endif()

file(MAKE_DIRECTORY ${CURRENT_PACKAGES_DIR}/tmp)

# Save library files
file(RENAME ${CURRENT_PACKAGES_DIR}/lib/${PLIBSYS_FILENAME}.lib ${CURRENT_PACKAGES_DIR}/tmp/plibsys.lib)
file(RENAME ${CURRENT_PACKAGES_DIR}/debug/lib/${PLIBSYS_FILENAME}.lib ${CURRENT_PACKAGES_DIR}/tmp/plibsys_debug.lib)

# Remove unused shared libraries
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/lib)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/lib)

file(MAKE_DIRECTORY ${CURRENT_PACKAGES_DIR}/lib)
file(MAKE_DIRECTORY ${CURRENT_PACKAGES_DIR}/debug/lib)

# Re-install library files
file(RENAME ${CURRENT_PACKAGES_DIR}/tmp/plibsys.lib ${CURRENT_PACKAGES_DIR}/lib/plibsys.lib)
file(RENAME ${CURRENT_PACKAGES_DIR}/tmp/plibsys_debug.lib ${CURRENT_PACKAGES_DIR}/debug/lib/plibsys.lib)

# Remove duplicate library files (already installed)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/tmp)

vcpkg_copy_pdbs()
