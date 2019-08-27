include(vcpkg_common_functions)

set(VCPKG_LIBRARY_LINKAGE dynamic)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO sccn/liblsl
    REF 1.13.0-b11 # NOTE: when updating version, also change it in the parameter to vcpkg_configure_cmake
    SHA512 212f28070b8239dc176d2e35bf4091896babbf7688e4cbe1c2bb0c3788f317ce2a80f92d4b008c6e577b01a09e8faf65228d396ff13e9ade0c1ffdc5e08cb9e5
    HEAD_REF master
	PATCHES
		fix-install.patch
)

vcpkg_configure_cmake(
	SOURCE_PATH ${SOURCE_PATH}
	PREFER_NINJA
	OPTIONS
		-DLSL_BUILD_STATIC=OFF
		-DLSL_UNIXFOLDERS=ON
		-DLSL_NO_FANCY_LIBNAME=ON
		-Dlslgitrevision="1.13.0-b11"
		-Dlslgitbranch="master"
)

vcpkg_install_cmake()
vcpkg_copy_pdbs()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)

file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/liblsl RENAME copyright)
file(INSTALL ${SOURCE_PATH}/README.md DESTINATION ${CURRENT_PACKAGES_DIR}/share/liblsl)
