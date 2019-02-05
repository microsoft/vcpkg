include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO googlecartographer/cartographer
    REF a7ed7e224f98b396762c865b81b62dc3abea2e81
    SHA512 2ab167c1c314591b4916baf70b8ad92ae542986c3578319d2454c904adae10f8027bc696579d6e2864d3606a6711563b82438e847527cad4ab0c2bd603a63eb7
    HEAD_REF master
	PATCHES
        ${CMAKE_CURRENT_LIST_DIR}/fix-find-packages.patch
        ${CMAKE_CURRENT_LIST_DIR}/disable-C2338-cartographer.patch
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DGFLAGS_PREFER_EXPORTED_GFLAGS_CMAKE_CONFIGURATION=OFF 
        -DGLOG_PREFER_EXPORTED_GLOG_CMAKE_CONFIGURATION=OFF 
        -Dgtest_disable_pthreads=ON 
        -DCMAKE_USE_PTHREADS_INIT=OFF
        -DCMAKE_WINDOWS_EXPORT_ALL_SYMBOLS=ON
    OPTIONS_DEBUG
        -DFORCE_DEBUG_BUILD=True
)

vcpkg_install_cmake()
vcpkg_fixup_cmake_targets(CONFIG_PATH share/cartographer)
vcpkg_copy_pdbs()

# Clean
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)

# Handle copyright of cartographer
file(COPY ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/cartographer)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/cartographer/LICENSE ${CURRENT_PACKAGES_DIR}/share/cartographer/copyright)
