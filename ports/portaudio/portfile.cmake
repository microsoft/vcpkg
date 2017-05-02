# Common Ambient Variables:
#   VCPKG_ROOT_DIR = <C:/path/to/current/vcpkg>
#   TARGET_TRIPLET is the current triplet (${VCPKG_TARGET_ARCHITECTURE}-windows, etc)
#   PORT is the current port name (zlib, etc)
#   CURRENT_BUILDTREES_DIR = ${VCPKG_ROOT_DIR}/buildtrees/${PORT}
#   CURRENT_PACKAGES_DIR  = ${VCPKG_ROOT_DIR}/packages/${PORT}_${TARGET_TRIPLET}
#

include(vcpkg_common_functions)
set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/portaudio)
set(ASIO_PATH ${CURRENT_BUILDTREES_DIR}/src/ASIOSDK2.3)

vcpkg_download_distfile(ARCHIVE
    URLS "http://www.portaudio.com/archives/pa_stable_v190600_20161030.tgz"
    FILENAME "pa_stable_v190600_20161030.tgz"
    SHA512 7ec692cbd8c23878b029fad9d9fd63a021f57e60c4921f602995a2fca070c29f17a280c7f2da5966c4aad29d28434538452f4c822eacf3a60af59a6dc8e9704c
)

vcpkg_download_distfile(ARCHIVE2
    URLS "http://www.steinberg.net/sdk_downloads/asiosdk2.3.zip"
    FILENAME "asiosdk2.3.zip"
    SHA512 aba21883cd026a789395757f7dcc127d7d6372965693ddc3794c8adfc3a9675c255cedf2a87177729fa0b094e1bdb4de9d2e47555c61ddd6976c24d71cbd5e38
)

vcpkg_extract_source_archive(${ARCHIVE})
vcpkg_extract_source_archive(${ARCHIVE2})

vcpkg_apply_patches(
        SOURCE_PATH ${SOURCE_PATH}
        PATCHES
                ${CMAKE_CURRENT_LIST_DIR}/cmakelists-install.patch)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS -DPA_USE_ASIO=1
)

vcpkg_install_cmake()

# Remove static builds from dynamic builds and otherwise
# Remove x86 and x64 from resulting files
if (VCPKG_CRT_LINKAGE STREQUAL dynamic)
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

# Handle copyright
file(COPY ${SOURCE_PATH}/LICENSE.txt DESTINATION ${CURRENT_PACKAGES_DIR}/share/portaudio)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/portaudio/LICENSE.txt ${CURRENT_PACKAGES_DIR}/share/portaudio/copyright)

file(COPY "${ASIO_PATH}/Steinberg ASIO Licensing Agreement.pdf" DESTINATION ${CURRENT_PACKAGES_DIR}/share/ASIOSDK2.3)

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
