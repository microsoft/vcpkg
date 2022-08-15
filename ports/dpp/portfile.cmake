vcpkg_from_github(
	OUT_SOURCE_PATH SOURCE_PATH
	REPO brainboxdotcc/DPP
	REF 104a34c4f2422d02f457437f6a6c5fbbf3396b24
	SHA512 29647eb3d1d34d9e48a346a4bdc1875c57593844df2c2a6c104979f3a5769caf3d5ca66f92e1781a7506e3b136fcc20a3be17e3d1995c16bf3cff048dce3e1a3
	HEAD_REF master
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(NO_PREFIX_CORRECTION)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share/dpp")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/bin" "${CURRENT_PACKAGES_DIR}/debug/bin")
endif()

file(
	INSTALL "${SOURCE_PATH}/LICENSE"
	DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}"
	RENAME copyright
)
