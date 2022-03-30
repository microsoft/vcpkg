vcpkg_from_github(
	OUT_SOURCE_PATH SOURCE_PATH
	REPO RealTimeChris/DiscordCoreAPI
	REF f3bf337b0e6142e04fc8ce89044aa13a82c206c1
	SHA512 06be2dd1dfc0a8214bac68533b85021102c86c3c763710602c40f75ce4538038fa41ce08951be67a0d2e7a9c792c980394fba18bc87e236fefcb206292396a97
	HEAD_REF main
)

vcpkg_cmake_configure(
	SOURCE_PATH "${SOURCE_PATH}"
)

vcpkg_cmake_install()

if (VCPKG_LIBRARY_LINKAGE STREQUAL "static")
	file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/bin" "${CURRENT_PACKAGES_DIR}/bin")
endif()
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

file(
	INSTALL "${SOURCE_PATH}/License"
	DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}"
	RENAME copyright
)
