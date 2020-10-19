vcpkg_fail_port_install(ON_TARGET "UWP" "iOS" "Android")
vcpkg_fail_port_install(ON_ARCH "x86" "arm")
vcpkg_check_linkage(ONLY_DYNAMIC_LIBRARY)

find_program(GIT git)

set(GIT_URL "https://github.com/DragonJoker/Ashes.git")
set(GIT_BRANCH "master")
set(GIT_REV "752a6fef9971e43744884300617ad99d78d1d631")
set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/${PORT}-${GIT_REV})

if(NOT EXISTS "${SOURCE_PATH}/.git")
	vcpkg_execute_required_process(
		COMMAND ${GIT} clone ${GIT_URL} ${SOURCE_PATH}/ -b ${GIT_BRANCH}
		WORKING_DIRECTORY ${CURRENT_BUILDTREES_DIR}
		LOGNAME clone
	)
	vcpkg_execute_required_process(
		COMMAND ${GIT} checkout ${GIT_REV}
		WORKING_DIRECTORY ${SOURCE_PATH}
		LOGNAME checkout
	)
	vcpkg_execute_required_process(
		COMMAND ${GIT} submodule update --init external/Vulkan-Headers
		WORKING_DIRECTORY ${SOURCE_PATH}
		LOGNAME submodule
	)
endif()
vcpkg_configure_cmake(
	SOURCE_PATH ${SOURCE_PATH}
	PREFER_NINJA
	OPTIONS
		-DCMAKE_INSTALL_PREFIX=${CURRENT_INSTALLED_DIR}
		-DPROJECTS_USE_PRECOMPILED_HEADERS=OFF
		-DASHES_BUILD_TEMPLATES=OFF
		-DASHES_BUILD_TESTS=OFF
		-DASHES_BUILD_INFO=OFF
		-DASHES_BUILD_SAMPLES=OFF
)

vcpkg_install_cmake()
file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/ashes RENAME copyright)
vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/ashes)
