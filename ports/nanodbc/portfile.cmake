# Only static libraries are supported.
# See https://github.com/nanodbc/nanodbc/issues/13
vcpkg_check_linkage(ONLY_STATIC_LIBRARY)
	
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO nanodbc/nanodbc
    REF fe1d590991da30dc9cb71676c4d80cb2d9acb49e
    SHA512 9c7e638b15b3c7ce418374c22a76be4f3f5901e7736938a8b0549b312bb7fa80bc8d34b2a52242a5b94196bb0994481a36e043a4f71cdc1d9af778915d017ac2
    HEAD_REF master
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
# Legacy, remove at release of v2.13
		-DNANODBC_EXAMPLES=OFF
		-DNANODBC_TEST=OFF
		-DNANODBC_USE_UNICODE=ON
# /Legacy
        -DNANODBC_DISABLE_EXAMPLES=ON
        -DNANODBC_DISABLE_TESTS=ON
        -DNANODBC_ENABLE_UNICODE=OFF
)

vcpkg_install_cmake()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
if(EXISTS ${CURRENT_PACKAGES_DIR}/cmake)
    vcpkg_fixup_cmake_targets(CONFIG_PATH cmake)
endif()

file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
