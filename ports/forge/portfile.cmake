include(vcpkg_common_functions)

if(NOT VCPKG_TARGET_ARCHITECTURE STREQUAL "x64")
    message(FATAL_ERROR "This port currently only supports x64 architecture")
endif()

set(ForgeVersion v1.0.3)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO arrayfire/forge
    REF ${ForgeVersion}
    SHA512 e1a7688c1c3ab4659401463c5d025917b6e5766129446aefbebe0d580756cd2cc07256ddda9b20899690765220e5467b9209e00476c80ea6a51a1a0c0e9da616
    HEAD_REF master
)

set(BuildSharedLib ON)
if(${VCPKG_LIBRARY_LINKAGE} STREQUAL "static")
    set(BuildSharedLib OFF)
	vcpkg_apply_patches(
		SOURCE_PATH ${SOURCE_PATH}
		PATCHES
		    ${CMAKE_CURRENT_LIST_DIR}/static_build.patch
			${CMAKE_CURRENT_LIST_DIR}/forge_targets_fix.patch
	)
else()
	vcpkg_apply_patches(
		SOURCE_PATH ${SOURCE_PATH}
		PATCHES ${CMAKE_CURRENT_LIST_DIR}/forge_targets_fix.patch
	)
endif()

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
	OPTIONS
		-DBUILD_SHARED_LIBS=${BuildSharedLib}
		-DFG_BUILD_DOCS=OFF
		-DFG_BUILD_EXAMPLES=OFF
)

vcpkg_install_cmake()

vcpkg_fixup_cmake_targets(CONFIG_PATH cmake)

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/examples)

if(VCPKG_LIBRARY_LINKAGE STREQUAL "dynamic")
    file(MAKE_DIRECTORY ${CURRENT_PACKAGES_DIR}/bin)
    file(RENAME ${CURRENT_PACKAGES_DIR}/lib/forge.dll ${CURRENT_PACKAGES_DIR}/bin/forge.dll)
    file(MAKE_DIRECTORY ${CURRENT_PACKAGES_DIR}/debug/bin)
    file(RENAME ${CURRENT_PACKAGES_DIR}/debug/lib/forge.dll ${CURRENT_PACKAGES_DIR}/debug/bin/forge.dll)
endif()

if(WIN32 AND VCPKG_LIBRARY_LINKAGE STREQUAL "dynamic")
    file(GLOB ForgeInstalledDeps ${CURRENT_PACKAGES_DIR}/lib/*.dll)
    file(GLOB ForgeInstalledDebugDeps ${CURRENT_PACKAGES_DIR}/debug/lib/*.dll)
    file(REMOVE ${ForgeInstalledDeps})
    file(REMOVE ${ForgeInstalledDebugDeps})
endif()

file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/forge RENAME copyright)
