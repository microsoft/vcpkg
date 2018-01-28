include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO googlecartographer/cartographer
    REF 0.3.0
    SHA512  34c40e438acd91815c3d4f73b350e430839b13ad0a20428ffa8417b801918994589b2abca1094cc6f1748ea2358ba84e9e97bd1c56e4d9c3ce9c6b5a455ca233
    HEAD_REF master
)

vcpkg_apply_patches(
    SOURCE_PATH ${SOURCE_PATH}
    PATCHES
        ${CMAKE_CURRENT_LIST_DIR}/fix-find-packages.patch
)

#Although the dynamic version is built, but here is no export (.lib) for the dll
set(VCPKG_LIBRARY_LINKAGE static)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    OPTIONS        
        -DGFLAGS_PREFER_EXPORTED_GFLAGS_CMAKE_CONFIGURATION=OFF 
        -DGLOG_PREFER_EXPORTED_GLOG_CMAKE_CONFIGURATION=OFF 
		-Dgtest_disable_pthreads=ON 
		-DCMAKE_USE_PTHREADS_INIT=OFF     
	OPTIONS_DEBUG
		-DFORCE_DEBUG_BUILD=True
)

vcpkg_install_cmake()


vcpkg_copy_pdbs()

# Clean
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)

# Handle copyright of cartographer
file(COPY ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/cartographer)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/cartographer/LICENSE ${CURRENT_PACKAGES_DIR}/share/cartographer/copyright)
