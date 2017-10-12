include(vcpkg_common_functions)
set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/SignalR-Client-Cpp-1.0.0-beta1)

vcpkg_download_distfile(ARCHIVE
    URLS "https://github.com/aspnet/SignalR-Client-Cpp/archive/1.0.0-beta1.tar.gz"
    FILENAME "SignalR-Client-Cpp-1.0.0-beta1.tar.gz"
    SHA512 b38f6f946f1499080071949cbcf574405118f9acfb469441e5b5b0df3e5f0d277a83b30e0d613dc5e54732b9071e3273dac1ee65129f994d5a60eef0e45bdf6c
)
vcpkg_extract_source_archive(${ARCHIVE})

vcpkg_apply_patches(
    SOURCE_PATH ${SOURCE_PATH}
    PATCHES
		${CMAKE_CURRENT_LIST_DIR}/0001_cmake.patch
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
	OPTIONS_DEBUG
		-DCPPREST_SO=${CURRENT_INSTALLED_DIR}/debug/lib/cpprest_2_9.lib
	OPTIONS_RELEASE
		-DCPPREST_SO=${CURRENT_INSTALLED_DIR}/lib/cpprest_2_9.lib
    OPTIONS
		-DCPPREST_INCLUDE_DIR=${CURRENT_INSTALLED_DIR}/include
        -DDISABLE_TESTS=ON
)

vcpkg_install_cmake()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

# copy license
file(COPY ${SOURCE_PATH}/LICENSE.txt DESTINATION ${CURRENT_PACKAGES_DIR}/share/signalrclient)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/signalrclient/LICENSE.txt ${CURRENT_PACKAGES_DIR}/share/signalrclient/copyright)
