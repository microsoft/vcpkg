vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO eyalroz/cuda-api-wrappers
    REF v0.6.2
    SHA512 4365b052d761d4ab0a840e084b64227348bb97d51826791442672afc4648f7b782fd2b862d91a0b5e88b140e5857e4a1a0a44686fa2c7b4fb380bb2f53adef91
    HEAD_REF master
)

vcpkg_cmake_configure(
	SOURCE_PATH "${SOURCE_PATH}"
	OPTIONS
	-DCAW_BUILD_EXAMPLES=OFF
	)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(
PACKAGE_NAME cuda-api-wrappers
CONFIG_PATH lib/cmake
)

set(CAW_CMAKE_PACKAGE_FILES_DIR ${CURRENT_PACKAGES_DIR}/share/cuda-api-wrappers)

file(GLOB packageFiles ${CAW_CMAKE_PACKAGE_FILES_DIR}/cuda-api-wrappers/*)
foreach(pkgFile ${packageFiles})
	get_filename_component(fileName ${pkgFile} NAME)
    file(RENAME ${pkgFile} ${CAW_CMAKE_PACKAGE_FILES_DIR}/${fileName})
endforeach()

file(REMOVE_RECURSE "${CAW_CMAKE_PACKAGE_FILES_DIR}/cuda-api-wrappers")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/lib" "${CURRENT_PACKAGES_DIR}/lib")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug")

file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
