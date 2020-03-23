include(vcpkg_common_functions)

vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO GPUOpen-LibrariesAndSDKs/D3D12MemoryAllocator
	REF v1.0.0+vs2017
	SHA512 7318607d757a24c11b5bcc1b930ed6ad0fc8cb902f728b3e811eb8bc3ec1a026b903c8099f055c8dcc404a9f3cf0346450be4244cfbe9456f32c9d3887584e95
    HEAD_REF master
)

file(COPY ${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt DESTINATION ${SOURCE_PATH})

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
	OPTIONS_DEBUG
		-DDISABLE_INSTALL_HEADER=ON
)

vcpkg_install_cmake()
vcpkg_copy_pdbs()
vcpkg_fixup_cmake_targets(CONFIG_PATH share/d3d12memory-allocator)

# Handle copyright
configure_file(${SOURCE_PATH}/LICENSE.txt ${CURRENT_PACKAGES_DIR}/share/d3d12memory-allocator/copyright COPYONLY)
