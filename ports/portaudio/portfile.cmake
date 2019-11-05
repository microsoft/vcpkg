include(vcpkg_common_functions)

vcpkg_from_git(
    OUT_SOURCE_PATH SOURCE_PATH
    URL https://git.assembla.com/portaudio.git
    REF c5d2c51bd6fe354d0ee1119ba932bfebd3ebfacc
)

# NOTE: the ASIO backend will be built automatically if the ASIO-SDK is provided
# in a sibling folder of the portaudio source in vcpkg/buildtrees/portaudio/src
vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DPA_USE_DS=ON
        -DPA_USE_WASAPI=ON
        -DPA_USE_WDMKS=ON
        -DPA_USE_WMME=ON
        -DPA_ENABLE_DEBUG_OUTPUT:BOOL=ON
)

vcpkg_install_cmake()

# Remove static builds from dynamic builds and otherwise
# Remove x86 and x64 from resulting files
if (NOT VCPKG_CMAKE_SYSTEM_NAME OR VCPKG_CMAKE_SYSTEM_NAME STREQUAL "WindowsStore")
	if (VCPKG_LIBRARY_LINKAGE STREQUAL dynamic)
		file (REMOVE ${CURRENT_PACKAGES_DIR}/lib/portaudio_static_${VCPKG_TARGET_ARCHITECTURE}.lib)
		file (REMOVE ${CURRENT_PACKAGES_DIR}/debug/lib/portaudio_static_${VCPKG_TARGET_ARCHITECTURE}.lib)

		file (RENAME ${CURRENT_PACKAGES_DIR}/lib/portaudio_${VCPKG_TARGET_ARCHITECTURE}.lib ${CURRENT_PACKAGES_DIR}/lib/portaudio.lib)
		file (RENAME ${CURRENT_PACKAGES_DIR}/debug/lib/portaudio_${VCPKG_TARGET_ARCHITECTURE}.lib ${CURRENT_PACKAGES_DIR}/debug/lib/portaudio.lib)
	else ()
		file (RENAME ${CURRENT_PACKAGES_DIR}/lib/portaudio_static_${VCPKG_TARGET_ARCHITECTURE}.lib ${CURRENT_PACKAGES_DIR}/lib/portaudio.lib)
		file (RENAME ${CURRENT_PACKAGES_DIR}/debug/lib/portaudio_static_${VCPKG_TARGET_ARCHITECTURE}.lib ${CURRENT_PACKAGES_DIR}/debug/lib/portaudio.lib)
		file (REMOVE ${CURRENT_PACKAGES_DIR}/lib/portaudio_${VCPKG_TARGET_ARCHITECTURE}.lib)
		file (REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/bin)
		file (REMOVE ${CURRENT_PACKAGES_DIR}/debug/lib/portaudio_${VCPKG_TARGET_ARCHITECTURE}.lib)
		file (REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/bin)
	endif ()
endif ()

vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/${PORT})
vcpkg_copy_pdbs()

# Handle copyright
file(COPY ${SOURCE_PATH}/LICENSE.txt DESTINATION ${CURRENT_PACKAGES_DIR}/share/portaudio)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/portaudio/LICENSE.txt ${CURRENT_PACKAGES_DIR}/share/portaudio/copyright)

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)