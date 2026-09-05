# Note: upstream GitLab instance at https://graphics.rwth-aachen.de:9000 often goes down
vcpkg_download_distfile(ARCHIVE
    URLS "https://www.openmesh.org/media/Releases/${VERSION}/OpenMesh-${VERSION}.0.tar.gz"
    FILENAME "OpenMesh-${VERSION}.tar.gz"
    SHA512 f6d082c58d31be4baff8f42f02a471fd655f0485da6a0a93fbb05c02670b86c9b9238e6d7bebb065a20e6e7264da4eb7c60f95ade590c752e0e3eb656e5835b1
)

vcpkg_extract_source_archive(
    SOURCE_PATH
    ARCHIVE "${ARCHIVE}"
    PATCHES
        fix-library-install-path.patch
        fix-pkgconfig.patch
        support-arm64-win.patch
)

if(VCPKG_LIBRARY_LINKAGE STREQUAL "dynamic")
  set(OPENMESH_BUILD_SHARED ON)
else()
  set(OPENMESH_BUILD_SHARED OFF)
endif()

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DBUILD_APPS=OFF
        -DVCI_COMMON_DO_NOT_COPY_POST_BUILD=ON
        -DVCI_NO_LIBRARY_INSTALL=ON
        -DOPENMESH_BUILD_SHARED=${OPENMESH_BUILD_SHARED}
	MAYBE_UNUSED_VARIABLES
		OPENMESH_BUILD_SHARED
        # [TODO]: add apps as feature, requires qt5 and freeglut
)

vcpkg_cmake_install()
vcpkg_copy_pdbs()
vcpkg_cmake_config_fixup(PACKAGE_NAME OpenMesh CONFIG_PATH "share/OpenMesh/cmake")
vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/include/OpenMesh/Tools/VDPM/xpm")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
