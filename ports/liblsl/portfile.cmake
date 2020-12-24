set(VCPKG_LIBRARY_LINKAGE dynamic)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO sccn/liblsl
    REF 1.13.1 # NOTE: when updating version, also change it in the parameter to vcpkg_configure_cmake
    SHA512 95cfd69cff86eb7de62624775f3037dd71a5240a6ad82c12d9340bfaf2c38c25ac9e884b01635bf71e27fcd9ce385602d8fa347c61b6ce10cf2bb7f0ad761282
    HEAD_REF master
)

vcpkg_configure_cmake(
	SOURCE_PATH ${SOURCE_PATH}
	PREFER_NINJA
	OPTIONS
		-DLSL_BUILD_STATIC=OFF
		-DLSL_UNIXFOLDERS=ON
		-DLSL_NO_FANCY_LIBNAME=ON
		-Dlslgitrevision="1.13.1"
		-Dlslgitbranch="master"
)

vcpkg_install_cmake()
vcpkg_copy_pdbs()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)

if(VCPKG_TARGET_IS_WINDOWS)
	file(REMOVE ${CURRENT_PACKAGES_DIR}/debug/bin/lslver.exe)
	file(MAKE_DIRECTORY ${CURRENT_PACKAGES_DIR}/tools/lslver/)
	file(RENAME ${CURRENT_PACKAGES_DIR}/bin/lslver.exe ${CURRENT_PACKAGES_DIR}/tools/lslver/lslver.exe)
endif()

file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/liblsl RENAME copyright)
file(INSTALL ${SOURCE_PATH}/README.md DESTINATION ${CURRENT_PACKAGES_DIR}/share/liblsl)
