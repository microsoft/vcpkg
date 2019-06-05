include(vcpkg_common_functions)

vcpkg_check_linkage(ONLY_DYNAMIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO sccn/liblsl
    REF 1.13.0-b6 # NOTE: when updating version, also change it in the parameter to vcpkg_configure_cmake
    SHA512 fb98cdd73de5f13e97f639ba3f2f836d46ce28cdcb2246584728f296eb647e2c9c069534470a603b10d7dc34ab8978bf246e2187428ab231a925feb0b7024c89
    HEAD_REF master
)

vcpkg_configure_cmake(
	SOURCE_PATH ${SOURCE_PATH}
	PREFER_NINJA
	OPTIONS
		-DLSL_BUILD_STATIC=OFF
		-DLSL_UNIXFOLDERS=ON
		-DLSL_NO_FANCY_LIBNAME=ON
		-Dlslgitrevision="1.13.0-b6"
		-Dlslgitbranch="master"
)

vcpkg_install_cmake()
vcpkg_copy_pdbs()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)
file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/liblsl RENAME copyright)
file(INSTALL ${SOURCE_PATH}/README.md DESTINATION ${CURRENT_PACKAGES_DIR}/share/liblsl)
