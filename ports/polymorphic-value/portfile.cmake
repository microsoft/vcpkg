vcpkg_from_github(
	OUT_SOURCE_PATH SOURCE_PATH
	REPO jbcoe/polymorphic_value
	REF 8b386a006c68c25c8f8c119c1f9620a916fb5afc #v1.3.0
	SHA512 4b131b5d7c86d589418d85f25afcee70ceb48c11d2ea807ef0e97667ba273ee27659ebf95a2a7aefb6379e43bb8e5f3c25d7921cfa348ca53db4b56a5336933c
	HEAD_REF main
)

vcpkg_cmake_configure(
	SOURCE_PATH "${SOURCE_PATH}"
	OPTIONS
		-DBUILD_TESTING=OFF
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/polymorphic_value)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/lib")

file(INSTALL "${SOURCE_PATH}/LICENSE.txt" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)

