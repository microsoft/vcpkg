set(MSVC_USE_STATIC_CRT_VALUE OFF)
if(VCPKG_CRT_LINKAGE STREQUAL "static")
	if(VCPKG_LIBRARY_LINKAGE STREQUAL "dynamic")
	    message(FATAL_ERROR "Ceres does not currently support mixing static CRT and dynamic library linkage")
	endif()
	set(MSVC_USE_STATIC_CRT_VALUE ON)
endif()

include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO googlecartographer/cartographer
    REF 0.3.0
    SHA512 901638931817ae91fd723a831463ad7901b6f704a07a5bd8bde755c621e75c4d9fef7066977b4a3d723f707fa443c693b4c5927593ff2ce17255b9cb9bebbd4c
    HEAD_REF master
)

vcpkg_apply_patches(
    SOURCE_PATH ${SOURCE_PATH}
    PATCHES
        ${CMAKE_CURRENT_LIST_DIR}/fix-find-packages.patch
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    OPTIONS        
        -DGFLAGS_PREFER_EXPORTED_GFLAGS_CMAKE_CONFIGURATION=OFF 
        -DGLOG_PREFER_EXPORTED_GLOG_CMAKE_CONFIGURATION=OFF 
		-Dgtest_disable_pthreads=ON 
        -DMSVC_USE_STATIC_CRT=${MSVC_USE_STATIC_CRT_VALUE}
)

vcpkg_install_cmake()
vcpkg_fixup_cmake_targets(CONFIG_PATH "CMake")

vcpkg_copy_pdbs()


# Clean
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)

# Handle copyright of suitesparse and metis
file(COPY ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/cartographer)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/cartographer/LICENSE ${CURRENT_PACKAGES_DIR}/share/cartographer/copyright)
