include(vcpkg_common_functions)

vcpkg_download_distfile(ARCHIVE
    URLS "http://www.portaudio.com/archives/pa_stable_v190600_20161030.tgz"
    FILENAME "pa_stable_v190600_20161030.tgz"
    SHA512 7ec692cbd8c23878b029fad9d9fd63a021f57e60c4921f602995a2fca070c29f17a280c7f2da5966c4aad29d28434538452f4c822eacf3a60af59a6dc8e9704c
)
vcpkg_extract_source_archive_ex(
    OUT_SOURCE_PATH SOURCE_PATH
    ARCHIVE ${ARCHIVE}
    PATCHES
        cmakelists-install.patch
        find_dsound.patch
        wasapi_support.patch
        crt_linkage_build_config.patch
        pa_win_waveformat.patch
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
if (WIN32)
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
vcpkg_copy_pdbs()

# Handle copyright
file(COPY ${SOURCE_PATH}/LICENSE.txt DESTINATION ${CURRENT_PACKAGES_DIR}/share/portaudio)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/portaudio/LICENSE.txt ${CURRENT_PACKAGES_DIR}/share/portaudio/copyright)

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
