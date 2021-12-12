vcpkg_check_linkage(ONLY_DYNAMIC_LIBRARY)

vcpkg_from_github(
	OUT_SOURCE_PATH SOURCE_PATH
	REPO PDAL/CAPI
	REF 1.8
	SHA512 6a5f4cb3d36b419f3cd195028c3e6dc17abf3cdb7495aa3df638bc1f842ba98243c73e051e9cfcd3afe22787309cb871374b152ded92e6e06f404cd7b1ae50bf
	HEAD_REF master
	PATCHES
		fix-docs-version.patch
		preserve-install-dir.patch
		remove-tests.patch
)

if(VCPKG_TARGET_IS_WINDOWS)
    string(APPEND VCPKG_C_FLAGS " -DNOMINMAX")
    string(APPEND VCPKG_CXX_FLAGS " -DNOMINMAX")
endif()

vcpkg_cmake_configure(
	SOURCE_PATH "${SOURCE_PATH}"
	OPTIONS
		-DPDALC_ENABLE_CODE_COVERAGE:BOOL=OFF
		-DCMAKE_DISABLE_FIND_PACKAGE_Doxygen:BOOL=ON
)

vcpkg_cmake_install()
vcpkg_copy_pdbs()

# Remove headers from debug
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

# Install copyright
file(INSTALL "${SOURCE_PATH}/LICENSE.md" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
