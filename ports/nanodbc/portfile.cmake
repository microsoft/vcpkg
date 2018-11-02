include(vcpkg_common_functions)

# Only static libraries are supported.
# See https://github.com/nanodbc/nanodbc/issues/13
if(VCPKG_USE_HEAD_VERSION) # v2.13
    vcpkg_check_linkage(ONLY_STATIC_LIBRARY)
else() # v2.12.4
    vcpkg_check_linkage(ONLY_DYNAMIC_LIBRARY)
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO nanodbc/nanodbc
    REF v2.12.4
    SHA512 b9a924516b2a777e5f1497774997672320548722ed53413b0a7ad5d503e2f8ca1099f5059a912b7aae410928f4c4edcdfd02e4cfbf415976cd222697b354b4e6
    HEAD_REF master
)

# Legacy, remove at release of v2.13
if(NOT VCPKG_USE_HEAD_VERSION)
vcpkg_apply_patches(
    SOURCE_PATH ${SOURCE_PATH}
    PATCHES
		${CMAKE_CURRENT_LIST_DIR}/0001_cmake.patch
		${CMAKE_CURRENT_LIST_DIR}/0002_msvc14_codecvt.patch
		${CMAKE_CURRENT_LIST_DIR}/0003_export_def.patch
		${CMAKE_CURRENT_LIST_DIR}/0004_unicode.patch
)
endif()
# /Legacy

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    OPTIONS
# Legacy, remove at release of v2.13
		-DNANODBC_EXAMPLES=OFF
		-DNANODBC_TEST=OFF
		-DNANODBC_USE_UNICODE=ON
# /Legacy
        -DNANODBC_DISABLE_EXAMPLES=ON
        -DNANODBC_DISABLE_TESTS=ON
        -DNANODBC_ENABLE_UNICODE=ON
)

vcpkg_install_cmake()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
if(EXISTS ${CURRENT_PACKAGES_DIR}/cmake)
    vcpkg_fixup_cmake_targets(CONFIG_PATH cmake)
endif()

file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/nanodbc RENAME copyright)
