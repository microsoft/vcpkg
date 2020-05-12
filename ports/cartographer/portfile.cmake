include(vcpkg_common_functions)

vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO googlecartographer/cartographer
    REF 1.0.0
    SHA512 4e3b38ee40d9758cbd51f087578b82efb7d1199b4b7696d31f45938ac06250caaea2b4d85ccb0a848c958ba187a0101ee95c87323ca236c613995b23b215041c
    HEAD_REF master
	PATCHES
        fix-find-packages.patch
        fix-build-error.patch
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DGFLAGS_PREFER_EXPORTED_GFLAGS_CMAKE_CONFIGURATION=OFF
        -DGLOG_PREFER_EXPORTED_GLOG_CMAKE_CONFIGURATION=OFF
        -Dgtest_disable_pthreads=ON
        -DCMAKE_USE_PTHREADS_INIT=OFF
    OPTIONS_DEBUG
        -DFORCE_DEBUG_BUILD=True
)

vcpkg_install_cmake()
vcpkg_fixup_cmake_targets()
vcpkg_copy_pdbs()

# Clean
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)

# Handle copyright of cartographer
file(COPY ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/cartographer)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/cartographer/LICENSE ${CURRENT_PACKAGES_DIR}/share/cartographer/copyright)
