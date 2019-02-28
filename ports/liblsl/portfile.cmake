include(vcpkg_common_functions)

vcpkg_check_linkage(ONLY_DYNAMIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO sccn/liblsl
    REF v1.13.0-b4 # NOTE: when updating version, also change it in the parameter to vcpkg_configure_cmake
    SHA512 19bc587afcff315385e7bab1f88cf4edd315acfda61a630b23ffe4c59bc0f5aa570f0a979071f2b60009bb4d4b8ce08c98c414dc5b88042556b2501f4b8dcb79
    HEAD_REF master
    PATCHES hardcode-version.patch fix-runtime-destination.patch
)

vcpkg_configure_cmake(
	SOURCE_PATH ${SOURCE_PATH}
	PREFER_NINJA
	OPTIONS
		-DLSL_BUILD_STATIC=OFF
		-DLSL_UNIXFOLDERS=ON
		-DLSL_NO_FANCY_LIBNAME=ON
		-Dlslgitrevision="v1.13.0-b4"
		-Dlslgitbranch="master"
)

vcpkg_install_cmake()
vcpkg_copy_pdbs()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)
file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/liblsl RENAME copyright)
file(INSTALL ${SOURCE_PATH}/README.md DESTINATION ${CURRENT_PACKAGES_DIR}/share/liblsl)
