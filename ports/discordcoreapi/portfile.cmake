vcpkg_from_github(
	OUT_SOURCE_PATH SOURCE_PATH
	REPO RealTimeChris/DiscordCoreAPI
	REF 3011861d7af1c7c171988a3f0d6300572634340b
	SHA512 c70b4073573ff69058831d5a494aed0ae6a120431a30250930897abe37e964ace5a94418f30a063c21a97a2bf52ceefd3e8925ef3998e885da6560c71184f4da
	HEAD_REF main
)

vcpkg_cmake_configure(
	SOURCE_PATH "${SOURCE_PATH}"
)

if ("${VCPKG_TARGET_TRIPLET}" STREQUAL "x64-linux")
	set(VCPKG_CXX_FLAGS "-std=gnu++2a" "-fcoroutines" "-fconcepts" "-lpthread" "-O3")
endif()

vcpkg_cmake_install()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/bin" "${CURRENT_PACKAGES_DIR}/bin")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

file(
	INSTALL "${SOURCE_PATH}/License"
	DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}"
	RENAME copyright
)
