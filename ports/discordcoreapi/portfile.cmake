vcpkg_from_github(
	OUT_SOURCE_PATH SOURCE_PATH
	REPO RealTimeChris/DiscordCoreAPI
	REF c3997d40614f1c3996f0f1358a865e199f202b6d
	SHA512 5ed2537e0c3593ba4f374056eafb3a8c77d26c363fbff89bffd103578e48a23061f40c5b2981647bb9258b7ae0364e74470ee180ce7b97675a872f29f8fb0c7d
	HEAD_REF main
)

vcpkg_cmake_configure(
	SOURCE_PATH "${SOURCE_PATH}"
)

vcpkg_cmake_install()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/bin" "${CURRENT_PACKAGES_DIR}/bin")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

file(
	INSTALL "${SOURCE_PATH}/License"
	DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}"
	RENAME copyright
)
